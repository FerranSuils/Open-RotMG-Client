#!/usr/bin/env python3
import argparse
import hashlib
import io
from pathlib import Path
import shutil
import subprocess
from urllib.request import urlopen
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parent
VERSION = "0.7.1"
URL = f"https://github.com/ruffle-rs/ruffle/releases/download/v{VERSION}/ruffle-{VERSION}-web-selfhosted.zip"
SHA256 = "ef12edbee135d581a9cd523837d746da30a07a64dbf1cf472d2e472c656f4b5e"


def prepare_ruffle():
    cache = ROOT / f".ruffle-{VERSION}.zip"
    if cache.exists():
        print(f"Using cached Ruffle {VERSION}", flush=True)
        data = cache.read_bytes()
    else:
        print(f"Downloading Ruffle {VERSION}: {URL}", flush=True)
        with urlopen(URL, timeout=60) as response:
            data = response.read()
    actual = hashlib.sha256(data).hexdigest()
    if actual != SHA256:
        raise RuntimeError(f"Ruffle checksum mismatch: expected {SHA256}, got {actual}. Remove {cache} and rerun.")
    if not cache.exists():
        cache.write_bytes(data)
    with ZipFile(io.BytesIO(data)) as archive:
        assets = [name for name in archive.namelist() if name.endswith((".js", ".wasm")) or name in ("LICENSE_MIT", "LICENSE_APACHE")]
        archive.extractall(ROOT / "vendor", members=assets)
    print(f"Prepared Ruffle {VERSION} from verified archive", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Prepare Ruffle and start the OpenRotMG development backend.")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--prepare-only", action="store_true", help="Install Ruffle without starting the backend")
    mode.add_argument("--dev-control", action="store_true", help="Enable the backend's loopback script control")
    args = parser.parse_args()
    server = ROOT.parent / "server"
    if not args.prepare_only:
        if not (server / "Cargo.toml").is_file():
            parser.error(f"Missing sibling Rust server: {server / 'Cargo.toml'}. Clone https://github.com/OpenRotMG/server beside the client repository.")
        if shutil.which("cargo") is None:
            parser.error("Cargo not found. Install Rust/Cargo from https://rustup.rs/ and rerun.")
    prepare_ruffle()
    if not args.prepare_only:
        command = ["cargo", "run"] + (["--", "--dev-control"] if args.dev_control else [])
        print(f"Starting backend in {server}\nClient: http://127.0.0.1:18923/", flush=True)
        try:
            raise SystemExit(subprocess.call(command, cwd=server))
        except KeyboardInterrupt:
            raise SystemExit(130)
