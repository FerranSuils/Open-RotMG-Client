<h1><img src=".github/readme-icon.png" width="44" height="44" align="absmiddle" alt=""> Open RotMG / Client</h1>

Realm of the Mad God **123.5.1** client, running through Ruffle.

## Run locally

The server's `./run.sh 8080` downloads this client automatically. You only need this checkout to work on the client yourself.

Install Python 3, prepare the client, then tell your server to use it:

```sh
./run.sh --prepare-only
/path/to/server/run.sh 8080 --local-client "$PWD"
```

Open the local URL printed by the server. Server setup: https://github.com/OpenRotMG/Open-RotMG-Server

---

Join Discord: https://discord.gg/EwZWNzzYwP
