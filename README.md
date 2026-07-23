# Stationary BESS Digital Twin

**A physics-based digital twin of a stationary lithium iron phosphate (LFP) battery energy storage system** — coupling an electrochemical–thermal cell model, temperature-dependent degradation, and a realistic Battery Management System (BMS) with sensor error, state estimation, and protection logic.

Built in MATLAB/Simulink and validated against Schimpe et al. (2018). The cell-level twin is complete and is being extended toward a full grid-connected BESS (pack → balancing → power electronics).

---

## Highlights

- **Faithful LFP cell model** — OCV(SOC, T), separable internal resistance R(SOC, T, direction), voltage hysteresis, self-discharge, and a 0-D lumped thermal model (Sony US26650FTC1).
- **Temperature-dependent degradation** — calendar aging (Arrhenius + Tafel anode-potential dependence, √t kernel) and cycle aging (Montes power-law with online half-cycle rainflow counting).
- **A realistic BMS, not an idealized one** — the BMS never sees the truth: it reads voltage, current and temperature through **sensor models with bias, gain error, noise and quantization**, then *estimates* state. The estimation error is itself a primary output.
  - SOC estimation: coulomb counting + event-based OCV correction, with LFP flat-plateau handling
  - SOH / capacity estimation: anchor-pair bookkeeping across the OCV steep zones
  - Internal-resistance estimation, dynamic State-of-Power limits, and a protection state machine (INIT / STANDBY / CHARGE / DISCHARGE / DERATE / FAULT) with hysteresis.
- **Dual-timescale architecture** — a slow model (1-hour steps, 10-year horizon) for energy, aging and state-estimation drift, and a fast model (100 Hz) for protection timing and mode behavior, sharing one timestep-agnostic BMS codebase.

## Validation & Results

| Result | Value |
|---|---|
| Model validation against Schimpe (2018) reference values | **57 / 57 checks pass** |
| Key anchors reproduced | OCV(50%)=3.28 V · thermal τ=1068 s · ΔT=7.07 K @ 1C · calendar loss 3.95 %/yr · Arrhenius ratio (35/25 °C)=1.31 |
| Simulated capacity fade over 10 years | **≈ 9 %** (SOH 1.00 → 0.91, 3.0 → 2.72 Ah) |
| BMS SOC estimation error (normal operation) | **median ≈ 0.9 %** |
| BMS SOH estimation — tracking of the *true* capacity fade | **within ≈ 0.7 %** at end of life |

> Note the two aging numbers are distinct: **~9 %** is the true physical capacity fade the cell undergoes; **~0.7 %** is how closely the BMS's *estimate* of remaining capacity follows that true fade over the decade.

## Architecture

The design follows a strict **truth-vs-belief** separation, mirroring a real deployment:

```
        TRUTH domain                         BELIEF domain
  ┌───────────────────────┐          ┌──────────────────────────┐
  │  Plant (physics)      │  V,I,T   │  BMS                     │
  │  electro-thermal +    │─────────▶│  sensors → estimation →  │
  │  aging + true SOC     │          │  limits → protection     │
  └───────────▲───────────┘          └────────────┬─────────────┘
              │        I_applied                   │ limits, mode, SOC_est
              │        ┌──────────────┐            │
              └────────│  EMS/dispatch │◀───────────┘
                       └──────────────┘
```

The BMS is firewalled from all true states — it acts only on estimates, exactly as hardware must.

## Repository Structure

```
├── Battery_sim_2.slx     # slow model — 1 h steps, 10-year electro-thermal + aging + BMS
├── BMS_Submodel.slx      # fast model — 100 Hz, protection / mode timing
├── main.m                # entry point: sets up workspace and runs the slow model
├── Cell/                 # electro-thermal + aging physics
│   ├── cell_thermal.m        OCV, R, hysteresis, self-discharge, 0-D thermal
│   ├── calendar_aging.m      Arrhenius + Tafel, √t kernel
│   ├── cycle_aging.m         Montes power-law + rainflow
│   └── current_limiter.m     power → current dispatch
├── BMS/                  # sensor models, estimators, limits, protection
│   ├── bms_sensor_model.m    bias / gain / noise / quantization / lag
│   ├── bms_soc_estimator.m   coulomb counting + OCV correction
│   ├── bms_soh_estimator.m   anchor-pair capacity estimation
│   ├── bms_r_estimator.m     ΔV/ΔI resistance estimation
│   ├── bms_limits.m          dynamic State-of-Power limits
│   ├── bms_mode.m            protection state machine
│   └── bms_config.m          single source of truth for all thresholds
├── Data/                 # parameters, drive profiles, lookup tables
├── Test/                 # validation & analysis scripts
│   ├── validate_model.m      57-check validation suite vs Schimpe (2018)
│   ├── test_estimators.m     BMS estimation unit tests
│   ├── test_mode.m           protection state-machine unit tests
│   └── inspect_simulink.m    headless Simulink structural auditor
└── docs/                 # design documents
```

## Getting Started

Requires MATLAB / Simulink (R2024a+).

```matlab
% Run the 10-year cell-level simulation
main

% Validate the model against Schimpe (2018) reference values
cd Test; validate_model
```

## Roadmap

- [x] Cell electro-thermal model + temperature-dependent aging (validated)
- [x] BMS: sensor models, SOC/SOH/R estimation, dynamic limits, protection
- [ ] Closed-loop BMS in the slow model (dispatch on *estimated* SOC)
- [ ] Pack scaling (series/parallel blocks, per-cell scatter, worst-cell aggregation)
- [ ] Passive cell balancing
- [ ] Power electronics: inverter + transformer → full grid-connected BESS

## Reference

M. Schimpe et al., *"Energy efficiency evaluation of a stationary lithium-ion battery container storage system via electro-thermal modeling and detailed component analysis,"* **Applied Energy 210 (2018) 211–229**, and the accompanying degradation-modeling work (TUM dissertation).

Cell: Sony US26650FTC1 — LFP-C, 3.0 Ah nominal, 3.2 V.
