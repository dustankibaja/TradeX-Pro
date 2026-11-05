# Emtifize AI — v2 MT5 read-only DEMO account dashboard

This branch extends the successful phone-to-engine heartbeat integration. A verified Windows MT5 DEMO worker now captures broker-reported balance, equity, free margin, floating P&L, open positions, and recent **closing deals**. These are shown only on the dedicated Trading engine screen. Other original trading screens still contain clearly marked sample data.

## Integration with MT5 AI Bot
Server implementation: `dustankibaja/mt5-forex-trading-bot`
branch `feature/read-only-status-api-2026-11`.

1. On a Windows computer with MT5 and Python, run the engine in dry-run:
   `python scripts/run_live.py --dry-run`.
2. Set `BOT_STATUS_READ_TOKEN` to a securely random 32+ character value.
3. Run `python scripts/serve_status.py` from `mt5-ai-bot/`.
4. Use a **private, trusted HTTPS reverse proxy or VPN tunnel** to reach the
   loopback-only `http://127.0.0.1:8787/v1/status` API.
5. In Flutter, tap the orange DEMO DATA banner, enter the HTTPS base URL
   and **read-only** pairing token, then tap Check connection.

The token is only stored in memory for that screen and never committed
or embedded in an APK. No trade placement, risk change, start/stop or
broker credential entry is possible. This is intentionally single-operator
proof-of-integration, **not** a multiuser commercial authentication system.

## Integrity and presentation rules
- Status is reported OFFLINE if the heartbeat is more than 30 seconds old.
- Error and unauthorized states are visible; failures are not silently
  treated as online.
- The app displays a persistent DEMO DATA banner over every existing
  trading screen because their balances, signals, charts and analytics
  are still mocked. Auto-trading toggle is locked OFF.
- For production, require OIDC/OAuth, short-lived bearer scopes, TLS,
  token rotation, device revocation, observability and broker reconciliation.
- Never expose the raw Python status port to the Internet.
- Do not trade on a funded account before successful independent
  strategy and MT5 demo forward validation.


## v2 demo-account upgrade (required on BOTH Windows and Android)

- Windows bot source: `dustankibaja/mt5-forex-trading-bot`, branch
  `feature/read-only-demo-account-2026-11`, based on the previously
  working `feature/demo-phone-pairing-2026-11`.
- Android app source: `dustankibaja/TradeX-Pro`, branch
  `feature/real-demo-dashboard-2026-11`, APK version `1.0.1+2`.
- API adds **authenticated GET /v1/demo-account** alongside /v1/status.
  It returns allowlisted DEMO financial figures only while the worker
  reports fresh `dry_run` status; all write verbs remain rejected.
- The source worker fetches MT5 data in the same authenticated DEMO
  terminal context, never from Flutter. Neither broker passwords,
  account numbers, server names, tickets, comments nor credentials
  are serialized to the API. Account change, broker disconnection,
  stop, unexpected data, or stale data hide all account figures.
- Phone screen polls every 15 seconds while visible, and replaces
  figures with unavailable on disconnection. Pairing token remains
  in screen memory only and is cleared when leaving the screen.
- The app shows the latest 20 positions and 20 closing **deal records**
  within a 7-day lookback; not a reconstructed win rate or full
  strategy journal. Existing manual demo trades may appear; the bot
  itself stays `--dry-run` and does NOT place trades.
- If Android installation fails due to a different GitHub Actions
  debug signing key, uninstall the prior Emtifize AI Demo version
  and install the new APK. This clears the old temporary pairing
  fields. Re-enter the new token and tailnet URL.
- Never deploy a funded account, disclose token, or expose the
  local Python port to the public Internet.

The API and Flutter client use HTTPS-over-Tailscale Serve only. A
screen showing RUNNING does not prove strategy profitability.
