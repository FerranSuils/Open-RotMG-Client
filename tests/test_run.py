import hashlib
import io
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from unittest.mock import patch
from zipfile import ZipFile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import run


class RufflePreparationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cache = run.ROOT / f".ruffle-{run.VERSION}.zip"
        if not cls.cache.is_file():
            raise RuntimeError("Run python3 run.py --prepare-only before launcher tests")
        if hashlib.sha256(cls.cache.read_bytes()).hexdigest() != run.SHA256:
            raise RuntimeError("Launcher test archive checksum mismatch")
        with ZipFile(cls.cache) as archive:
            cls.originals = {name: archive.read(name) for name in run.WASM_SHA256}
        cls.patched_hashes = {
            "172de42e6619eac8f371.wasm": "4cf2c5941611b66eee3c60846f0e0540516b9e2ebc131d2158ef1fba629c9d35",
            "878d548199cddef07035.wasm": "c3ca1ddf2f88e5ddd6dc670f8d962db8c38f4255fd518d1a90dfbfa2815430db",
        }

    def test_exact_patch_preserves_binary_length(self):
        for name, original in self.originals.items():
            with self.subTest(name=name):
                result = run.patch_alpha(name, original)
                self.assertEqual(len(result), len(original))
                self.assertEqual(hashlib.sha256(result).hexdigest(), self.patched_hashes[name])

    def test_modified_build_rejected(self):
        for name, original in self.originals.items():
            with self.subTest(name=name), self.assertRaisesRegex(RuntimeError, "WASM checksum mismatch"):
                run.patch_alpha(name, original[:-1] + bytes([original[-1] ^ 1]))

    def test_missing_or_duplicate_shader_rejected(self):
        name = next(iter(self.originals))
        for data in [b"no shader", run.ALPHA_ANCHOR * 2]:
            with self.subTest(count=data.count(run.ALPHA_ANCHOR)):
                with patch.dict(run.WASM_SHA256, {name: hashlib.sha256(data).hexdigest()}):
                    with self.assertRaisesRegex(RuntimeError, "ALPHA shader mismatch"):
                        run.patch_alpha(name, data)

    def test_preparation_is_repeatable_and_preserves_official_archive(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            cache = root / self.cache.name
            shutil.copyfile(self.cache, cache)
            with patch.object(run, "ROOT", root), redirect_stdout(io.StringIO()):
                for _ in range(2):
                    run.prepare_ruffle()
                    for name, expected in self.patched_hashes.items():
                        path = root / "vendor" / name
                        self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), expected)
                        path.write_bytes(b"discarded generated asset")
            self.assertEqual(hashlib.sha256(cache.read_bytes()).hexdigest(), run.SHA256)
            self.assertTrue((root / "vendor" / "LICENSE_MIT").is_file())
            self.assertTrue((root / "vendor" / "LICENSE_APACHE").is_file())

    def test_corrupt_archive_rejected_before_extraction(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / self.cache.name).write_bytes(b"corrupt archive")
            with patch.object(run, "ROOT", root), redirect_stdout(io.StringIO()):
                with self.assertRaisesRegex(RuntimeError, "Ruffle checksum mismatch"):
                    run.prepare_ruffle()
            self.assertFalse((root / "vendor").exists())


if __name__ == "__main__":
    unittest.main()
