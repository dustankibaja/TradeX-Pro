# APEX Trade — v1 MT5 read-only connection

This branch connects a **real read-only engine heartbeat**, not a trading account.
Other screens use hardcoded sample values until a secured account-data API exists.

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
