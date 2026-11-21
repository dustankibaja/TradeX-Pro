# F.1 Windows Runtime Acceptance Runbook

## Scope and safety boundary

This runbook validates the read-only Product Beta F.1 research workflow using
only the packaged synthetic EUR/USD H1 CSV. It does not require, launch, or
connect MetaTrader 5. Do not run a broker terminal, provide credentials, change
settings, or invoke any order operation during this test.

The operator must separately authorize the launch of the checksum-verified
Windows package on an isolated Windows host. Until then, this document is a
test plan, not runtime evidence.

## Package preflight

1. Record the artifact ID, GitHub run URL, Flutter commit, backend pin, inner
   ZIP SHA-256 and the bundled checksum-file value.
2. Confirm the inner ZIP checksum equals the bundled checksum before extraction.
3. Extract the complete ZIP to a new private directory. Do not merge it with an
   earlier beta extraction.
4. Confirm these files exist before launch:
   - `apex_trade.exe`
   - `runtime/emtifize-backtest.exe`
   - `runtime/emtifize-strategy.exe`
   - `runtime/emtifize-onboarding.exe`
   - `runtime/emtifize-readiness.exe`
   - `SYNTHETIC-DEMO-EURUSD-H1.csv`
5. Confirm the Windows workflow pins the reviewed backend commit. The test
   fixture must never be presented as a broker or live-market data source.

## Windows acceptance script

| Step | Action | Expected result | Evidence |
| --- | --- | --- | --- |
| 1 | Launch `apex_trade.exe` from the extracted directory. | App starts without elevation, install, MT5, or trading prompts. | Screenshot and process/version details. |
| 2 | Select **Use offline research workspace**. | Workspace says no broker account is connected; execution is locked; Trading Readiness is absent. | Screenshot. |
| 3 | Open Strategy Studio and create or load a confirmed saved strategy. | A versioned strategy with a configuration hash is available. | Strategy name, version, hash. |
| 4 | Open Backtests and select the packaged synthetic EUR/USD H1 CSV. | Dataset validation displays synthetic warning, timestamp range, source, and SHA-256. | Screenshot and validation values. |
| 5 | Run the historical simulation. | Results state **Historical simulation**, not broker execution; no broker process, account, or order dialog appears. | Screenshot. |
| 6 | Inspect summary and chart. | Ending simulated equity, realized/unrealized P&L, costs, drawdown, warnings, and equity curve render. | Screenshot. |
| 7 | Inspect signals and rejected signals. | BUY/SELL/NO SIGNAL explanations reference completed candles; warm-up and rejection reasons are human-readable. | Screenshot or copied examples. |
| 8 | Export. | JSON, CSV, and text report are written to the Windows export folder; JSON preserves manifest/provenance/costs and CSV correctly quotes special characters. | Paths, hashes, and file snippets. |
| 9 | Close and relaunch the app. | The saved simulation reopens with run ID, deterministic fingerprint, metadata, trades, and chart intact. | Before/after screenshots. |
| 10 | Attempt malformed CSV and an unwritable export target, if the isolated host can simulate it safely. | Clear validation/export errors; no data is silently overwritten. | Error text and confirmation that prior saved run remains. |

## Deterministic checks

Run the same confirmed strategy, fixture, date range, initial balance, and cost
model twice. The run IDs must differ; the simulation-content fingerprint,
metrics, and ledger must match. A different cost input or dataset hash must
produce different reproducibility evidence.

## Android boundary

Automated verification establishes that Android displays no local Windows
runtime route. Actual device testing must additionally confirm:

1. The screen explicitly says local simulation is Windows-only.
2. Saved records can be displayed if present in app storage.
3. **Export / share** opens the Android system chooser for the JSON, CSV, and
   report files.
4. Cancelling the chooser causes no crash or false claim of sharing.
5. No broad storage permission is requested.

Android is not an F.1 simulation platform. It is a view/export companion only.

## Acceptance decision

Mark Windows runtime acceptance PASS only when every Windows step above has
recorded evidence. A passing package build or checksum alone is insufficient.
Keep E.1 incomplete and all execution controls locked regardless of F.1 result.
