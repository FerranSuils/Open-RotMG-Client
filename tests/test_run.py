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
            "172de42e6619eac8f371.wasm": "b59ba0f183efc7612431283527d116a277d9439f7e362a75d12ecb774150c3fe",
            "878d548199cddef07035.wasm": "1eb6684d691f0c533ae0f68630da2ad198fc9b6edfb1926a628f64ed4c7583d6",
        }

    def test_exact_patch_and_code_lengths(self):
        for name, original in self.originals.items():
            with self.subTest(name=name):
                result = run.patch_wasm(name, original)
                self.assertEqual(len(result), len(original) + 37)
                code_at, code_size, function_at, function_size, *_ = run.DISPOSED_FILL[name]
                for position, size, width in [(code_at, code_size, 4), (function_at, function_size, 2)]:
                    actual = sum((result[position + i] & 127) << (i * 7) for i in range(width))
                    self.assertEqual(actual, size + 37)
                self.assertEqual(hashlib.sha256(result).hexdigest(), self.patched_hashes[name])

    def test_modified_build_rejected(self):
        for name, original in self.originals.items():
            with self.subTest(name=name), self.assertRaisesRegex(RuntimeError, "WASM checksum mismatch"):
                run.patch_wasm(name, original[:-1] + bytes([original[-1] ^ 1]))

    def test_missing_or_duplicate_shader_rejected(self):
        name = next(iter(self.originals))
        for data in [b"no shader", run.ALPHA_ANCHOR * 2]:
            with self.subTest(count=data.count(run.ALPHA_ANCHOR)):
                with patch.dict(run.WASM_SHA256, {name: hashlib.sha256(data).hexdigest()}):
                    with self.assertRaisesRegex(RuntimeError, "ALPHA shader mismatch"):
                        run.patch_wasm(name, data)

    def test_misplaced_native_anchor_rejected(self):
        for name, original in self.originals.items():
            entry = list(run.DISPOSED_FILL[name])
            entry[4] += 1
            with self.subTest(name=name), patch.dict(run.DISPOSED_FILL, {name: tuple(entry)}):
                with self.assertRaisesRegex(RuntimeError, "disposed-fill anchor mismatch"):
                    run.patch_wasm(name, original)

    def test_native_code_length_overflow_rejected(self):
        name = next(iter(self.originals))
        entry = list(run.DISPOSED_FILL[name])
        entry[1] = 1 << 28
        with patch.dict(run.DISPOSED_FILL, {name: tuple(entry)}):
            with self.assertRaisesRegex(RuntimeError, "disposed-fill patch exceeds reserved length"):
                run.patch_wasm(name, self.originals[name])

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
