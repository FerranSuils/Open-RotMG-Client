(async () => {
  const player = window.RufflePlayer.newest().createPlayer();
  document.querySelector('#client').append(player);
  const heldKeys = new Map();
  player.addEventListener('keydown', event => heldKeys.set(event.code, event));
  player.addEventListener('keyup', event => heldKeys.delete(event.code));
  const releaseKeys = () => {
    const keys = [...heldKeys.values()];
    heldKeys.clear();
    for (const event of keys) window.dispatchEvent(new KeyboardEvent('keyup', event));
  };
  // Ruffle ignores key-up after losing focus, so release before its focusout handler runs.
  player.addEventListener('focusout', event => {
    if (!player.contains(event.relatedTarget)) releaseKeys();
  }, true);
  window.addEventListener('blur', releaseKeys);
  const accountEndpoint = new URL('/legacy-api/', location.href).href;
  const audioEndpoint = new URL('/sfx/', location.href).href;
  const socketEndpoint = new URL('/game', location.href);
  socketEndpoint.protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
  const movies = {game: '/client.swf', editor: '/native-texture-editor.swf'};
  const mode = document.querySelector('#client').dataset.mode;
  if (!Object.hasOwn(movies, mode)) throw new Error(`Unknown client mode: ${mode}`);
  if (mode === 'game') {
    // Random key linking this page's augment card overlay (server /panel.js) to its game socket.
    const key = Array.from(window.crypto.getRandomValues(new Uint8Array(16)), b => b.toString(16).padStart(2, '0')).join('');
    socketEndpoint.searchParams.set('panel', key);
    window.rotmgPanelKey = key;
  }
  // Options > Graphics > Hardware Acceleration (client-mods Mods.as) saves its choice in the MRGraphics
  // SharedObject, which Ruffle keeps base64-encoded in localStorage; Off draws with the CPU canvas renderer.
  const cpuOnly = (() => {
    try {
      const key = Object.keys(localStorage).find(k => k.split('/').pop() === 'MRGraphics');
      return key !== undefined && atob(localStorage.getItem(key)).includes('MR_RENDER_CPU');
    } catch {
      return false;
    }
  })();
  await player.ruffle().load({
    url: movies[mode],
    autoplay:'on',unmuteOverlay:'hidden',preferredRenderer:cpuOnly ? 'canvas' : 'wgpu-webgl',
    logLevel:'info',openUrlMode:'deny',allowScriptAccess:false,
    socketProxy:[{host:'127.0.0.1',port:2050,proxyUrl:socketEndpoint.href}],
    urlRewriteRules:[
      [/^https?:\/\/127\.0\.0\.1:8080\/(?=(?:char|account|fame|guild|picture)\/)/,accountEndpoint],
      [/^https?:\/\/realmofthemadgod\.appspot\.com\/sfx\//,audioEndpoint]
    ]
  });
  document.querySelector('#status').textContent = '';
})().catch(error => {
  document.querySelector('#status').textContent = String(error);
  console.error(error);
});
