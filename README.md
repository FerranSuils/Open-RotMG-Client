# OpenRotMG client

Realm of the Mad God **123.5.1** client, running through Ruffle.

## Local development

Requires Python 3 and Rust/Cargo: https://rustup.rs/ . Clone https://github.com/OpenRotMG/server into a sibling `server` directory.

Linux/macOS: `./run.sh` · Windows: `.\run.bat`

The launcher downloads verified Ruffle assets and starts the Rust backend. Open http://127.0.0.1:18923/ . The development map and gameplay rules are incomplete; historical fidelity is not yet verified.

Generated Ruffle includes hash-checked fixes for black sprite rectangles and disposed bitmap fills. The official archive and reference SWF stay unchanged.

Use `--prepare-only` to install Ruffle without starting the backend, or `--dev-control` to enable loopback script control.

Launcher tests: `python3 run.py --prepare-only`, then `python3 -m unittest discover -s tests`.

Discord: https://discord.gg/EwZWNzzYwP
