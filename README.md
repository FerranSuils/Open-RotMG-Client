# OpenRotMG client

Realm of the Mad God **123.5.1** client, running through Ruffle 0.7.1.

```sh
python3 -m http.server 18923 --bind 127.0.0.1
```

Open http://127.0.0.1:18923/ . The loading scene works; the retry error is expected until an account server exists.

**Start here:** `index.html` hosts the unchanged `client.swf`. Help connect it to the server without changing gameplay. `vendor/` contains Ruffle, not our own tooling.

The SWF was recovered from https://github.com/trapped/rotmg_svr at `593e490`; it is a private-server derivative, not a certified original. GPL-3.0 covers our page; third-party rights and Ruffle's included licenses remain unchanged.
