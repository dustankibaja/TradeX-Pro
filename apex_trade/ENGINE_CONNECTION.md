# Emtifize AI v1.2 — single-screen private DEMO bot console

This replaces the old fake trading platform with **one purpose-built screen**.
No onboarding, profile, subscription, fake charts/signals, demo numbers,
or bottom navigation. No account login required: the Windows MT5 account
is the identity; an HTTPS pairing secret provides private access.

## Visible features

1. **Connection**: HTTPS Tailscale Serve hostname; separate read-only and
   control tokens, both held in screen memory only and cleared on exit.
   Connection fields collapse after a successful pairing and can be reopened.
2. **Engine**: real authenticated worker status / demo guard / strategy /
   symbol(s) / last heartbeat. Automatic refresh every 15s while screen open.
3. **DEMO signal controls**: independent control token required. PAUSE
   signals immediately, RESUME only after the phone confirms intent and
   Windows checks the fresh broker DEMO identity, dry_run, and demo snapshot.
   The Windows manual `KILL_SWITCH` is NEVER cleared by phone controls.
4. **Account**: broker-reported DEMO balance, equity, free margin, floating
   P&L; collapsible open positions and last seven days' closing deals.
   No demo values are invented. On network failure, figures are hidden.

**Scope: Pausing or resuming signal *simulation* only.**
The worker stays `--dry-run --require-demo`; NO trades are ever placed
by the app, even on the broker demo account. This is not a remote trade order
terminal. Strategy profitability remains unproven.

## Windows v3 pairing and restart (existing user)

From `C:\Users\WingerAPP\mt5-forex-trading-bot\mt5-ai-bot` in PowerShell:

- Stop the previous worker/API processes after verifying their command line.
- Make sure there are no unexpected uncommitted code edits: `git status --short`.
- Because the original clone was single-branch, fetch v3 directly via fast-forward
  from its parent v2 code branch:

```powershell
git pull --ff-only origin feature/safe-demo-control-2026-11
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start_demo_phone_bridge.ps1
```

- MT5 desktop must remain signed into an MT5 broker **DEMO** account.
- The script now generates **TWO DIFFERENT TOKENS**:
  **READ-ONLY PAIRING TOKEN** and **DEMO CONTROL TOKEN**. Both are
  private credentials. Do not paste, screenshot or share either in chat.
- A brand-new bridge starts with **remote pause engaged**.
  This avoids accidentally resuming even dry-run signal calculations.
- The existing Tailscale `serve --bg 8787` HTTPS proxy can remain enabled.
  Use **Serve**, never public Funnel.
- If readback fails, app money fields remain unavailable. Source-only CI
  tests cannot prove your Windows broker or Android device is connected.

## Android upgrade

- Version `1.2.0+4`, debug APK from the `feature/minimal-bot-console-2026-11`
  branch's successful Android GitHub workflow.
- If Android cannot update due to a different debug signing key, uninstall
  the prior debug app first (this removes local app data), then install v1.2.
- The new app launches directly to **Emtifize AI**; enter the HTTPS host,
  read-only token, and separate control token (optional if only monitoring).
- Tap **Connect securely** to view DEMO status. The Paused/Running control
  is visible after pairing. Resume requires a confirmation.
- Keep Windows, MT5, and Tailscale running on both devices.

## Security limitations

- Tailscale private HTTPS transport, two long random tokens, Windows
  DEMO-only guards; still a single-operator prototype, not
  enterprise-grade user/account authentication.
- No public port 8787, no order execution endpoints, no password or MT5
  login supplied to Flutter or GitHub.
- No persisted pairing secrets. Re-enter on new app launch.
- Broker snapshots include private DEMO account financial data;
  keep Tailscale access restricted to your own devices.
- Emergency manual Windows kill switch always wins.
- Never enable funded-account trading until strategy testing and
  independent live demo forward performance justify it.
