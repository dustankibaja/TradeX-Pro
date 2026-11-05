# Emtifize AI v1.3 — scan once, remember bot, auto-reconnect

Android app now uses **encrypted Keystore-backed pairing persistence** and in-app QR scanning.
No account balances, trade history or broker credentials are saved offline.

## First-time connection

1. Update Windows backend to `feature/persistent-qr-pairing-2026-11`.
2. Install its pinned QR dependency with `.\.venv\Scripts\python.exe -m pip install -r requirements.txt`.
3. Keep MetaTrader 5 on your DEMO account, and Tailscale Serve enabled privately.
4. Restart `scripts/start_demo_phone_bridge.ps1`. It creates or reloads two
   encrypted Windows DPAPI credentials. On a connected Windows desktop,
   a PRIVATE local pairing QR window appears automatically. It is not saved to disk.
5. On Android, install Emtifize v1.3 APK. Tap **Scan QR on Windows PC**, grant
   camera permission and scan the screen. The app verifies a private HTTPS
   Tailscale address and distinct strong secrets before connecting.
6. Close the QR window. It is a secret equivalent to read/control passwords:
   do NOT screenshot, share or upload it.

Manual HTTPS host and token fields remain available when camera is unavailable.

## Future app launches

- A successful pairing is encrypted on the phone with `flutter_secure_storage`.
- The app loads the host and secrets automatically at launch, gets the most
  recent status and demo portfolio, and rechecks every 15 seconds while visible.
- On returning from background, it makes a fresh request immediately.
- When the PC, MT5, Tailscale or backend is offline, the app shows
  DISCONNECTED and does not show stale broker values, but **retains pairing**
  and retries next time. Its connection is not a permanently running background socket.
- The Windows bridge **reuses encrypted secrets** on the same Windows account
  across restarts. It does NOT generate new passwords every time.
- In settings, **Forget this bot** deletes the saved encrypted pairing.
- Reinstalling app or clearing app data can erase stored pairing because Android
  backup is intentionally disabled. Re-scan if required.

## Reality and security

True availability over days requires an ON Windows PC or VPS with MT5 and
the backend running, plus a connected private Tailscale tailnet. The Flutter
app alone cannot maintain a stopped engine. Android battery restrictions or
disconnected Tailscale can delay reconnection.

The first QR includes BOTH the read token and control token. Guard the physical
PC screen carefully. In case of exposure, stop bridge, rotate DPAPI secrets,
then re-pair. Continue to use `--dry-run --require-demo`, and NEVER enable
funded trading based on these connection tests.

App source branch: `feature/secure-auto-reconnect-2026-11`.
Windows source branch: `feature/persistent-qr-pairing-2026-11`.
