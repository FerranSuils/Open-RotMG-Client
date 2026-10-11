# OpenRotMG client

Preserved Flash client and browser host for Realm of the Mad God build **123.5.1**.

## Contents

- `reference/123.5.1/`: recovered SWFs, immutable reference bytes.
- `flash/src/`: extracted ActionScript, embedded XML/data and sprites from the ViciousFate client family. This is the starting point for narrowly documented client changes.
- `browser/`: the Ruffle startup probe and pinned 0.7.1 runtime, using the `wgpu-webgl` renderer.
- `PROVENANCE.json`: source revisions and reference/runtime checksums.

These are community private-server derivatives. We have not authenticated an untouched official release, and the extracted source has not been rebuilt into the reference SWF.

## Browser startup probe

From this repository:

```sh
python3 -m http.server 18923 --bind 127.0.0.1
```

Open http://127.0.0.1:18923/browser/

The page loads the unmodified trapped reference SWF. Its CSP blocks external requests and rewrites the known localhost account endpoint to the local `/legacy-api/` path. Without an account backend, a loading scene followed by a retry/error is expected. This is a startup/rendering probe, not a playable game.

No TCP/WebSocket bridge is implemented yet. The server repo will own that bridge because it must control which backend destinations are reachable. Keep the Flash reference files unchanged; record gameplay or endpoint patches separately.

## Related repositories

Server: https://github.com/OpenRotMG/server

Research and additional historical clients in their upstream snapshots: https://github.com/OpenRotMG/research

## License

Our browser host, tooling and new client changes are GPL-3.0-or-later. Preserved third-party client source, binaries and game assets are not relicensed by the root LICENSE. Their existing notices and provenance remain applicable. Ruffle is redistributed under its MIT/Apache-2.0 terms, with both license texts retained in the runtime directory.

See THIRD_PARTY.md for publication scope.
