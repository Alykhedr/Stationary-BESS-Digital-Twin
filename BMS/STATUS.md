# BMS Layer — Shared Status & Conventions

Coordination file for both developers (Diaa & Ali) and their AI assistants.
**Update this file in the same commit as any BMS change.**
Plan of record: `docs/BMS_Layered_Plan.html` (+ review amendments below).

---

## Progress Tracker

| Item | Owner | Status | Notes |
|---|---|---|---|
| `bms_config.m` | BOTH (frozen at M0) | ✅ created, pending Ali review | all-numeric, verified loadable |
| `Data/ocv_table.mat` (shared OCV + hysteresis tables) | BOTH @ M0 | ✅ created, pending Ali review | structs `ocv`, `hys`, `meta`; BMS uses raw 25 °C table, no dUdT (documented in `meta.note`) |
| `Data/fixture_2week.mat` (recorded I/V/T/SOC_true) | ALI | ✅ exported | 337 samples (0–336 h) @ commit 9e67039; SOC 0.05–0.95, I −0.63…+1.16 A, T 19.8–25 °C |
| State bus definitions (`est_state`, `soh_state`, `r_state`, `mode_state`) | BOTH @ M0 | ⬜ not started | part of frozen contract — see "No persistent" below |
| `bms_init.m` | ALI (drafted by Diaa's side) | ✅ done, smoke-tested | seeded draws persisted in `Data/bms_scatter_seed.mat`; ⚠️ seeds SOC from OCV⁻¹(V_t0) with NO zone guard — if t0 is under load on the plateau the seed can be far off (fixture: seed 0.15 vs true 0.50, recovered at first snap t=4 h) |
| `bms_sensor_model.m` | DIAA | ✅ done, tests pass | embedded LCG noise (codegen-deterministic); state struct in/out |
| `bms_ocv_inverse.m` | DIAA | ✅ done, tests pass | ⚠️ signature changed: OCV/hys tables passed as ARGS (function blocks can't load .mat) — Ali attaches them as Parameters in .slx |
| `bms_soc_estimator.m` | DIAA | ✅ done, tests pass | ⚠️ signature: returns `corrected` as 2nd output (SOH anchor events); tables as args |
| `bms_soh_estimator.m` | DIAA | ✅ done, tests pass | plausibility window 0.5–1.5× Q_nom rejects bad anchors |
| `bms_r_estimator.m` | DIAA | ✅ done, tests pass | direction bin = sign of NEW current; plausibility window on R_new |
| `bms_limits.m` | ALI (drafted by Diaa) | 🔄 draft, tests pass | ⚠️ Ali to review/own; uses V_max_warn per amendment #2; returns `derate_active` 3rd output for bms_mode |
| `bms_mode.m` | ALI (drafted by Diaa's side) | ✅ done, tests pass | gates limits to 0 in FAULT; stores violated T-limit in state (`fault_T_limit`) so recovery checks the right threshold; same-tick release guarded; UV-at-low-T latched |
| `.slx` BMS subsystem + stub wiring | ALI (exclusive) | ⬜ not started | |
| `Test/test_estimators.m` | DIAA | ✅ sections 1–6 green | incl. draft limits tests (Ali to move into test_limits.m if preferred) |
| `Test/test_mode.m` | ALI (drafted) | ✅ 9 cases green | incl. chattering, latch, direction-specific T recovery |
| `Test/test_limits.m` | ALI | ⬜ optional | limits cases currently live in test_estimators §6 — move if preferred |
| End-to-end chain on fixture | BOTH | ✅ ran clean | sensors→est→limits→mode: 0 spurious FAULTs, modes STANDBY 50/CH 28/DIS 23 %, SOC err ≤4 % steady (spikes on 32 %/h ramp ticks are fixture alignment artifacts), Q_est 2.999 Ah |
| Gate-0 (stubs wired, bit-identical baseline) | BOTH | ⬜ | |
| Gate-1 (M1 handshake, 10-yr joint run) | BOTH | ⬜ | |

Legend: ✅ done · 🔄 in progress · ⬜ not started

---

## Plan Amendments (agreed deviations from the HTML plan)

1. **`SOC_est` is NOT a FAULT trigger.** The HTML plan lists SOC outside
   [0.02, 0.98] as a FAULT condition — this contradicts its own rule that the
   safety path must not depend on estimator health, and the dispatch parks at
   5/95 % true SOC routinely, so estimator drift would cause spurious FAULTs.
   `cfg.soc.protect_*` feed derating/warning only. Voltage protection covers
   true over/under-charge. → reflected in `bms_config.m` comments.
2. **Charge voltage headroom uses `V_max_warn` (3.55 V), not `V_max_protect`
   (3.60 V).** Otherwise the limiter steers V right up to the fault threshold
   and any 2 mV noise blip latches FAULT. Discharge side already does this
   (warn 2.50 / protect 2.00); charge side must be symmetric.
   → `I_ch_volt = (cfg.cell.V_max_warn − V_meas_max) / R_est_ch`
3. **Aux power accounting added** (`cfg.aux`): 2.76 W/module slave +
   81 W master (Schimpe Table 3). Log as energy ledger entry; do NOT subtract
   from cell power flow at single-cell phase (it's an AC-side system load).

---

## ⚠️ Hard Conventions — mistakes already made & fixed, do not repeat

### 1. NO `persistent` in MATLAB Function blocks
This project does not use `persistent` inside Simulink MATLAB Function blocks.
All stateful functions take state in AND out as an explicit struct argument:
```matlab
function [out, state] = bms_xxx(in, state, cfg, dt_h)
```
Ali wires state through Memory blocks with Bus objects in the `.slx`.
This is also what makes the dual-rate offline harness possible.
(Note `cell_thermal.m` has a commented-out persistent block — that's the scar.)

### 2. NO struct ports in Simulink — cfg via function call (AGREED CONVENTION)
Structs do not cross block boundaries, period. `cfg = bms_config();` and
`bms_tables()` are called INSIDE each `*_sl.m` wrapper (cheap — pure constants).
Core functions keep struct signatures for offline testing; only wrappers go
into the .slx. cfg fields stay ALL-NUMERIC anyway (mode enums are ints,
`cfg.bal.enable_modes = [2 1]`).

### 3. Time scaling: 1 simulation second = 1 hour, fixed step = 1
- `dt_h = 1` in the longevity twin; ALL functions take `dt_h` as an argument,
  never hard-code it (the high-rate harness passes 10 ms–1 s equivalents).
- All rates/time constants in cfg are per-hour (e.g. `T_lag_tau_h = 30/3600`).
- Memory blocks = 1-step = 1-hour delay. BMS acts on step k measurements;
  limits apply at step k+1. Keep this causality pattern.

### 4. Sign convention (Schimpe): I > 0 = CHARGE, I < 0 = DISCHARGE
Everywhere. `dU = I*R + sign(I)*U_Hys`. Wrong sign shows up as discharge
voltage above charge voltage (impossible — crossing V curves).

### 5. V_terminal routing bug (FIXED — don't reintroduce)
The thermal model's V_Terminal used to pass through a Memory block before
logging, so logged V was one step stale and `V_T ≈ OCV` without the dU term.
Fixed 2026-06-11. If V_terminal ever again equals OCV exactly while current
flows, suspect a Memory block sneaked back into the V path.
Feedback paths into `power dispatch` legitimately use Memory blocks
(algebraic-loop breaking) — only the LOGGING/measurement tap must be direct.

### 6. Project paths are set in `main.m` — keep it that way
`main.m` does `addpath(... 'Cell')` and `addpath(... 'Data')` via
`mfilename('fullpath')`. New folders (`BMS/`, `Test/`) need the same lines
added there — do NOT rely on MATLAB's current directory or savepath.
(The original "Undefined function 'calendar_aging'" bug was exactly this.)

### 7. OCV / hysteresis tables: ONE source
Until `Data/ocv_table.mat` exists, the only authoritative copy is inside
`Cell/cell_thermal.m`. Do not copy-paste the tables into BMS functions —
extract to the .mat at M0 and load from there in both plant and BMS.

### 8. The truth firewall
`SOC_true`, `SOH_true`, `R_i`, `Q_heat` are plant/logging signals ONLY.
No BMS function may take them as input. If a BMS function "needs" truth to
work, the design is wrong — raise it, don't wire it.

### 9. `.slx` is single-owner (Ali)
Diaa's AI must not edit `Battery_sim_2.slx`. All Diaa-side work is .m files
runnable against `Data/fixture_2week.mat`. This avoids binary merge conflicts
— git cannot merge .slx files. (Also: don't commit `slprj/`; it's gitignored.)

### 10. Stale git lock
If git refuses with "A lock file already exists": check for a zero-byte
`.git/index.lock` older than the current operation (GitHub Desktop leaves
them behind when interrupted). Verify no git process is mid-operation
before deleting the lock file.

---

## Simulink Adaptation Layer (`*_sl.m` wrappers) — THE convention

NO struct ports, NO buses, NO persistent anywhere in the .slx. Each core
function has a `*_sl.m` wrapper that goes inside the MATLAB Function block:
- scalar signals in/out only
- `cfg = bms_config();` and `bms_tables()` called INSIDE the wrapper
- each state field = one scalar output looped back through ONE Memory block;
  Memory initial conditions are documented in each wrapper header (= bms_init values)
- sensor biases (random draws) enter as Constant blocks wired to workspace
  scalars that `bms_init`/`Workspace_set` create

Wrappers (all verified BIT-IDENTICAL to the core chain over the 2-week fixture):
| Wrapper | State scalars through Memory |
|---|---|
| `bms_sensor_model_sl` (×3 instances: channel 1=V, 2=I, 3=T) | y_lag, noise_seed |
| `bms_soc_estimator_sl` | soc, t_rest, i_sign |
| `bms_soh_estimator_sl` | Q, Ah_acc, anchor_soc, has_anchor |
| `bms_r_estimator_sl` | V_prev, I_prev, R_ch, R_dis |
| `bms_limits_sl` | (stateless) |
| `bms_mode_sl` | mode, fault_code, dwell, latch, fault_T_limit |

⚠️ Wire dispatch to bms_mode_sl's GATED limits, not bms_limits_sl's raw ones.
⚠️ `bms_tables.m` mirrors `Data/ocv_table.mat` — test_estimators asserts equality;
   change them TOGETHER or the test fails.

## Architecture Decisions (discussion 2026-06-12)

### Three-part split (both models)
POWER DELIVERY (EMS) | ELECTRO-THERMAL | AGING — with the BMS as a LOOP
between power delivery and the plant, not a pipe:
- Downward: EMS current request → clamped by BMS gated limits → I_applied
  goes DIRECTLY to both electro-thermal and aging (not through BMS twice)
- Upward: plant truth (V, I, T) → BMS sensors → estimators → limits/mode →
  back to EMS. EMS never sees plant truth.
- Aging ↔ electro-thermal exchange (T, SOC, Q_actual) is internal plant
  physics — BMS has no part in it.
- BMS is permissive, not generative: it clamps/kills the EMS request
  (contactor = FAULT gating, binary), it never creates the setpoint and
  never throttles by dissipation (only balancing resistors burn energy).
- BMS hierarchy is PER RACK: slaves (sensing/balancing) per module ×13,
  ONE master per rack = one SOC estimate per rack, worst-cell (min/max
  aggregation) feeds the limit equations. Current single-cell model = rack
  of one cell. 8 racks = 8 independent BMS (Schimpe models 1, scales ×8).

### Consequences for the longevity twin (Battery_sim_2.slx)
- SOC integrator MOVES from power dispatch into electro-thermal (plant
  state). S_rate_per_h becomes an INTERNAL plant connection (thermal →
  SOC integrator) and is REMOVED from current_limiter's inputs.
- Q_actual → SOC integrator feedback (capacity fade, P0 item): wire
  Aging.Q_actual → Memory (init 3.0, breaks algebraic loop) → plant.
  dSOC/dt = I/Q_actual − s_rate(T).
- current_limiter slims to: (Pload−Ppv)/V → clamp to [−I_ch_max_dyn,
  +I_dis_max_dyn] → Ich/Idis split → P_bess. Dropped args: S_rate_per_h,
  SOC_min/max, static I_ch/dis_max, Q_nom, dt_h; SOC truth → SOC_est.
- Ich/Idis split = max(I_net,0) / max(−I_net,0) (two MinMax blocks).

### BMS_submodel.slx (NEW second simulation — high-rate context)
- 1 sim-second = 1 REAL second, fixed step 0.01 s. Purpose: thermal
  dynamics (τ≈18 min), sensor lag (30 s), protection latency, mode
  behavior. NOT for aging (negligible at these horizons — pre-age via
  initial Q if needed, e.g. init Rate Transition at 2.4 Ah for 80 % SOH).
- TIME CONVENTION (final, 2026-06-12): only TWO time variables exist in
  BMS_Submodel — `step_size` [sim-seconds, = 0.01] and `dt_h` [= 1, hours
  per Aging execution]. NO dt_h_fast or other derived variables. Wherever
  a fast-rate block needs the per-step duration in HOURS, write the
  expression `step_size/3600` INLINE (BMS c_dt constant, Thermal const
  block, SOC_step dt input). The `dt_h` argument of every bms_* function
  is in HOURS by contract (the _h suffix): fast blocks receive
  step_size/3600, the Aging interior receives dt_h = 1.
  Sanity: at 3 A, SOC moves ~33 %/simulated-hour in both models.
- MULTIRATE: Aging subsystem = atomic, sample time 3600 s, internal
  dt_h = 1 (processes one hour per execution).
- Fast→slow signals (T_degC, SOC, I_net) need the HOURLY MEAN, not a
  raw sample (ZOH at the boundary aliases; throughput would be wrong):
    Discrete-Time Integrator (FwdEuler, K=1, Ts=-1, init 0)
    → Rate Transition (deterministic, out Ts=3600)
    → Sum(+−) with Unit Delay (Ts=3600, init 0) on the − input,
      Unit Delay input taps the Rate Transition OUTPUT
    → Gain 1/3600  = true mean over the past hour
  One chain each for T_degC, SOC, I_net; Ich/Idis max-split done on the
  SLOW side (hourly dispatch = single-direction hours).
- Slow→fast (Q_actual, SOH): plain Rate Transition (ZOH hold), init 3.0.
- Integrator grows unbounded by design (no reset; differencing handles
  it; double precision fine for this model's short horizons).

## BMS_Submodel.slx — build progress (2026-06-12, Diaa)

Done so far (verified via model inspection):
- `Battery Thermal model` subsystem: cell_thermal + R_i lookup + SOC-step
  (discrete, dt fed externally) + V_Terminal Memory for loop breaking
- `Aging` subsystem: cycle_aging fn + Calendar_aging (Digital Clock→1/3600
  →tcal_h ✓, accumulator Sum+UnitDelay), Ich/Idis max-split inside,
  SOH = 1 − Qcyc − Qcal via Memory, Q_actual = Q_nom × SOH
- 3 × "Rate Changer" hourly-mean chains (T_degC, I_net, SOC):
  DTI → RateTransition → Sum(+−, UnitDelay on −, tapped from RT OUT)
  → 1/3600 ✓ all correct
- Q_actual slow→fast feedback wired through blk_70 (check init = 3.0)

🐛 FIXED 2026-06-12: Calendar_aging accumulator Sum was `+−`
   (Qcal[k] = dQcal − Qcal[k−1] → oscillates). Corrected to `++`.
   ⚠️ Sign convention reminder: ACCUMULATOR Sum = `++`;
   Rate-Changer DIFFERENCER Sum = `+−`. They look identical — check signs
   when copying either pattern.

✅ BMS subsystem BUILT programmatically (2026-06-12) and model COMPILES:
- 8 MATLAB Function blocks (sensor_V/I/T, r_est, soc_est, soh_est, limits,
  mode), each a thin call to its `*_sl` wrapper (wrappers must stay on path)
- 22 Memory blocks (one per state scalar, inits per wrapper headers;
  mem_Q init 3.0, mem_soc init = workspace var SOC0_est, seeds = nseedV/I/T)
- 9 Constants: channel ids, b_V/b_I/b_T/g_I (workspace), c_dt = step_size/3600
- Interface: in V_true/I_true/T_true → out SOC_est/I_ch_max/I_dis_max/
  mode_out/fault_code (gated limits from mode block, NOT raw from limits)
- Aging subsystem is atomic Ts=3600 (user); its internal Memory set to
  InheritSampleTime=on (was continuous — compile blocker, fixed)

WORKSPACE SETUP for BMS_Submodel (must run IN THIS ORDER — Workspace_set
clears vars):
  run('Data/Workspace_set.m'); load('WS_Variables.mat');
  dt_h = 1; step_size = 0.01;
  d = load('Data/bms_scatter_seed.mat');
  b_V/b_I/b_T/g_I/nseedV/I/T from d.draws;  SOC0_est = 0.5;
NO dt_h_fast variable — per-step hours are written INLINE as the
expression `step_size/3600` (BMS c_dt constant, Thermal const block).
Only two time variables exist in this model: step_size [s] and dt_h (=1,
hours per Aging execution).
→ TODO: put this in a dedicated BMS_Submodel_setup.m

Still open in BMS_Submodel:
- BMS subsystem ROOT inputs unconnected (V_true ← Thermal.V_Terminal
  pre-Memory tap, I_true ← fast I_net, T_true ← Thermal.T_deg_c)
- I_net and SOC Rate Changer INPUTS unconnected (need fast I_net source +
  SOC at root); root layout warning during subsystem creation may have
  dropped one edge — re-verify root connections
- power delivery / dispatch not yet placed (consumes BMS outputs)
- ⚠️ UNIT QUESTIONS to verify: root Zero-Order Hold Ts = 3600/step_size
  = 360000 sim-s = 100 h (should hourly be just 3600?); Battery Thermal
  Gain = dt_h applied to dTcell_dt [°C/s] — on the 0.01 s timebase the
  per-step multiplier should be step_size (0.01 s), not dt_h (=1)

## Sensor Error Budget (drawn values, seed 42, frozen in bms_scatter_seed.mat)

| Param | Drawn | Range (cfg) | Models | Effect |
|---|---|---|---|---|
| b_V | −0.50 mV | ±2 mV | AFE offset | <0.1 % SOC err per snap in steep zones (>2 % on plateau — why snapping there is forbidden) |
| b_I | **+9.01 mA** | ±10 mA | shunt zero-offset | **dominant**: +0.3 %SOC/h CC drift (~7 %/day) — the reason the OCV snap exists; Sprint-2 sweep b_I ∈ {1,5,10,20} mA |
| g_I | +0.232 % | ±0.5 % | shunt+amp gain | corrupts SOH Ah-bookkeeping more than SOC |
| b_T | +0.20 °C | ±1 °C | NTC tolerance | skews T-derate knees; matters near 0 °C charge cutoff |

Drawn ONCE (seeded), persisted, reused every run = same "physical board".
Redraw: change cfg.sens.rng_seed, call bms_init(..., true).
Current draw is near-worst-case on current, lucky on voltage — good test board.

## Where the voltage-based SOC correction lives

- Trigger + λ-ramp blend: `bms_soc_estimator.m` "corrector" section
  (rest ≥ 2 h → bms_ocv_inverse → λ = min(1,(t_rest−t_min)/t_min) → blend)
- V→SOC conversion: `bms_ocv_inverse.m` (hysteresis removal → 19-pt table
  inversion → steep-zone validity gate)
- In the model: `BMS_Submodel/BMS/soc_est` block (+ mem_t_rest, mem_i_sign)
- Config: cfg.est.{rest_current_thr, rest_time_min, ocv_corr_zones}
- NOT to be confused with: OCV temperature correction (plant-only,
  cell_thermal Step 3, deliberately unknown to the BMS) and sensor bias
  (never corrected — the BMS doesn't know it has one).

## Kalman filter — deliberate omission (Open Decision #1, resolved)

NO EKF in the baseline. Rationale (keep ready for supervisor questions):
1. LFP plateau (20–90 % SOC, ~0.07 V per 100 % SOC) → voltage innovation
   gain ≈ 0 → EKF silently degenerates to coulomb counting + tuning burden.
2. Where voltage IS informative (steep zones), the event-based OCV snap
   already uses it — and only when the information is real (rest,
   hysteresis-compensated, steep zone).
3. Mis-tuned Q/R on a low-observability plateau injects hysteresis/bias
   into SOC_est exactly where it can't be detected.
4. EKF needs the V-model in the loop (OCV + I·R + hysteresis); every model
   error becomes estimation error.
IF added later (P2, comparison study "EKF vs CC+OCV-snap under b_I sweep"
— thesis-grade): drop-in replacement for the CORE of bms_soc_estimator,
same wrapper/ports, +2 state scalars (covariance P, hysteresis state)
through 2 more Memory blocks. Nothing else changes.

## Function Signatures (freeze at M0)

```matlab
cfg                                  = bms_config()
[y_meas, sens_state]                 = bms_sensor_model(y_true, sens_state, cfg_sensor, dt_h)
[soc_ocv, valid]                     = bms_ocv_inverse(V_meas_rest, I_last_sign, SOC_hint, ocv_SOC, ocv_V, hys_SOC, hys_V, cfg)
%   ^ tables as explicit args: MATLAB Function blocks cannot load() .mat at
%     runtime; .slx attaches them as Parameters, harness loads ocv_table.mat
[y_meas, sens_state]                 = bms_sensor_model(y_true, sens_state, dt_h)   % supersedes line above; per-channel cfg lives inside sens_state
[SOC_est, corrected, est_state]      = bms_soc_estimator(I_meas, V_meas, est_state, Q_est, ocv_SOC, ocv_V, hys_SOC, hys_V, cfg, dt_h)
[SOH_est, Q_est, soh_state]          = bms_soh_estimator(SOC_est, corrected, I_meas, soh_state, cfg, dt_h)
[R_ch, R_dis, r_state]               = bms_r_estimator(V_meas, I_meas, r_state, cfg)
[I_ch_max, I_dis_max, derate_active] = bms_limits(V_meas_max, V_meas_min, T_meas_max, T_meas_min, SOC_est, Q_est, R_ch, R_dis, cfg, dt_h)   % stateless
[mode, I_ch_max_out, I_dis_max_out, fault_code, mode_state] ...
                                     = bms_mode(I_meas, V_meas_max, V_meas_min, T_meas_max, T_meas_min, derate_active, I_ch_max_in, I_dis_max_in, mode_state, cfg, dt_h)
%   ^ also gates the limits (0 in FAULT) so dispatch needs no special-casing
states                               = bms_init(cfg, V_meas_t0, ocv_SOC, ocv_V, hys_SOC, hys_V, regen_seed)
%   ^ runs OFFLINE once (Workspace_set/main), not in a function block;
%     returns .sens_V/.sens_I/.sens_T/.est/.soh/.r/.mode state structs
```
(Adjust at M0 if needed — then frozen.)
