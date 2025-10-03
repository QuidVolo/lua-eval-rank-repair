# Lua Code Evaluation — Rank & Repair (with tiny LÖVE harness)

![lua-tests](https://github.com/QuidVolo/lua-eval-rank-repair/actions/workflows/lua-tests.yml/badge.svg)](https://github.com/QuidVolo/lua-eval-rank-repair/actions/workflows/lua-tests.yml)

Minimal pack that ranks alternatives, repairs a bug (diff), and validates with pure-Lua tests + a tiny LÖVE harness. Includes a spawn scheduler, toy linter, micro-benchmark, GDScript port, and a weighted rubric.


This artifact mirrors common evaluator tasks:
1) **Rank** 3 alternate Lua solutions (best → worst) with short rationales.
2) **Repair** a buggy snippet and prove it with a tiny **LÖVE** test harness.
3) Provide a simple **rubric** used to judge snippets.

> Note: You can run the harness in [LÖVE](https://love2d.org/) by placing these files in a folder and executing `love .`

---

## 1) Ranking Task — `move_towards`

**Problem:** Move an entity towards a target at speed `speed` using delta time `dt`. Return the new position and whether the target was reached this frame.

### Solution A (Best)
```lua
-- A: clear, guards zero distance, no globals, returns reached flag
local function move_towards(x, y, tx, ty, speed, dt)
  local dx, dy = tx - x, ty - y
  local dist = math.sqrt(dx*dx + dy*dy)
  if dist == 0 then return x, y, true end
  local step = speed * dt
  if step >= dist then
    return tx, ty, true
  end
  local nx, ny = dx / dist, dy / dist
  return x + nx * step, y + ny * step, false
end
return move_towards
```

**Rationale:** Correctness guard (`dist==0`), no division by zero, constant-time, idiomatic math, returns a useful `reached` flag. **(Correctness, Readability, Performance, Testability = strong)**

### Solution B (Okay)
```lua
-- B: modifies input via table; repeats work; no explicit zero-dist guard
local function move_towards(e, target, speed, dt)
  local dx, dy = target.x - e.x, target.y - e.y
  local step = speed * dt
  local dist = math.sqrt(dx*dx + dy*dy)
  if step > dist then step = dist end
  e.x = e.x + dx/dist * step
  e.y = e.y + dy/dist * step
  return e
end
return move_towards
```

**Rationale:** Works but mutates input, returns no explicit reached flag, and risks `0/0` if already at target (implicit NaN). **(Correctness risk, Readability moderate)**

### Solution C (Worst)
```lua
-- C: ignores dt and speed scaling; global temp vars; pixel-step; jitter risk
x = x or 0; y = y or 0
function move_towards(tx, ty)
  if tx > x then x = x + 1 elseif tx < x then x = x - 1 end
  if ty > y then y = y + 1 elseif ty < y then y = y - 1 end
  return x, y
end
return move_towards
```

**Rationale:** Frame-dependent, ignores dt/speed, uses globals, no convergence guarantee for sub-pixel distances. **(Incorrect for spec; poor testability)**

**Ranking:** **A > B > C**.

---

## 2) Repair Task — `step_entity` (buggy → fixed)

### Bug Summary
- **Issue:** Division by zero and nil dereference when the entity is exactly at the target or when `e.pos` was not initialized.
- **Impact:** Runtime error or NaN position leading to jitter.
- **Fix:** Guard `dist==0`, ensure `e.pos` exists, avoid in-place mutation before validation, and return a `reached` flag.

See `buggy_spawn.lua` and `fixed_spawn.lua`. A unified diff is in `diff_patch.patch`.

---

## 3) Rubric Used (5 points)
1. **Correctness** – matches spec; handles edge cases (zero-distance, large dt, NaN).
2. **Readability** – clear names, single-responsibility function, no hidden globals.
3. **Idiomatic Lua** – local functions/vars, table use, math, module return.
4. **Performance** – avoid redundant math, constant-time logic, minimal allocations.
5. **Testability** – pure function shape, deterministic outputs, simple harness hooks.

---

## 4) Tiny LÖVE Harness
`main.lua` uses `fixed_spawn.lua` to move a dot to a target and displays the status. Replace with `buggy_spawn.lua` to reproduce the failure and compare behavior.

**How to run**
```bash
love .
```

**Files**
- `main.lua` – harness UI loop
- `fixed_spawn.lua` – repaired function
- `buggy_spawn.lua` – original buggy version
- `diff_patch.patch` – unified diff
- `README.md` – this file

---

## 5) How to test without LÖVE (pure Lua)
Install Lua 5.4 (or 5.3) locally and run:
```bash
lua tests.lua
```
You should see:
```
OK: all tests passed.
```

This runs:
- invariant checks on `fixed_spawn.lua` (no NaN, non-increasing distance, reach within a bound),
- deterministic property checks on random targets,
- a correctness test for `move_towards.lua`,
- and a schedule sanity check for `spawn_scheduler.lua`.

If you prefer visuals, use the **LÖVE harness**:
```bash
love .
```
Press **SPACE** to reset, **R** to randomize target.

---

## 6) Extras for evaluators
- **gd_step_entity.gd** — GDScript port (Godot) of the fixed step function.
- **perf_bench.lua** — micro-benchmark comparing a safe vs naive implementation.
- **static_check.lua** — tiny linter to flag global writes and risky `1/dist` patterns.
- **ranking_dataset.jsonl** — sample JSONL for rank/repair evaluation.
- **eval_rubric.yaml** — simple weighted rubric used in ranking.

**Run:**
```bash
lua perf_bench.lua
lua static_check.lua buggy_spawn.lua fixed_spawn.lua
```
