# Emtifize AI product beta

The same Flutter codebase now provides:

- a Windows-first, local DEMO account setup wizard and dashboard;
- the existing Android private monitoring and pairing companion.

The Windows wizard detects an installed MetaTrader 5 terminal and invokes the bundled local Python safety service. It prefers the account already authenticated in the official terminal, never accepts a brokerage password, rejects non-DEMO accounts, records only a protected account fingerprint/configuration, and keeps execution locked.

## Developer run

For an unpackaged development run, set `EMTIFIZE_BACKEND_PYTHON` to the backend virtual-environment Python executable and `EMTIFIZE_BACKEND_ROOT` to the `mt5-ai-bot` directory. Then run the Windows target. A release package instead contains `runtime/emtifize-onboarding.exe` and does not require customer Python.

The GitHub Windows workflow builds and tests both sides, assembles a standalone ZIP, and publishes its SHA-256 checksum. It is unsigned and DEMO-only. Do not arm execution or represent this milestone as broker compatibility certification.
