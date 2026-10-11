#!/usr/bin/env python3
import argparse
import functools
import hashlib
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import io
from pathlib import Path
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
    parser = argparse.ArgumentParser(description="Prepare Ruffle and serve the client locally.")
    parser.add_argument("--prepare-only", action="store_true", help="Install Ruffle without starting HTTP, for static builds")
    args = parser.parse_args()
    if args.prepare_only:
        prepare_ruffle()
    else:
        handler = functools.partial(SimpleHTTPRequestHandler, directory=str(ROOT))
        with ThreadingHTTPServer(("127.0.0.1", 18923), handler) as server:
            prepare_ruffle()
            print("Client: http://127.0.0.1:18923/\nGame backend is not started by this command yet.", flush=True)
            try:
                server.serve_forever()
            except KeyboardInterrupt:
                print("Stopped client web server", flush=True)
