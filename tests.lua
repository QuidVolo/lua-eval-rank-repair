-- tests.lua — run with:  lua tests.lua
local function approx_le(a, b, eps) return a <= b + (eps or 1e-7) end
local function not_nan(x) return x == x end

local function assert_true(cond, msg)
  if not cond then
    error("ASSERT FAILED: "..(msg or ""), 2)
  end
end

local function dist(x,y,tx,ty)
  local dx, dy = tx-x, ty-y
  return math.sqrt(dx*dx + dy*dy)
end

-- 1) Test fixed_spawn step_entity invariants
local step_entity = require("fixed_spawn")

do
  local e = { pos = {x=100,y=100}, speed = 120 }
  local target = { x=120, y=100 }
  local last = dist(e.pos.x, e.pos.y, target.x, target.y)
  local reached = false
  local iters = 0
  while not reached and iters < 1000 do
    local nx, ny, r = step_entity(e, target, 0.1)
    assert_true(not_nan(nx) and not_nan(ny), "NaN in step_entity")
    local d = dist(nx, ny, target.x, target.y)
    assert_true(approx_le(d, last, 1e-5), "Distance should be non-increasing")
    last, reached, iters = d, r, iters + 1
  end
  assert_true(reached, "Entity failed to reach target in time")
end

-- random property checks
do
  math.randomseed(42)
  for i=1,50 do
    local e = { pos = {x = math.random(0,600), y = math.random(0,400)}, speed = 200 }
    local target = { x = math.random(0,600), y = math.random(0,400) }
    local iters, reached = 0, false
    local last = dist(e.pos.x, e.pos.y, target.x, target.y)
    while not reached and iters < 2000 do
      local nx, ny, r = step_entity(e, target, 1/60)
      assert_true(not_nan(nx) and not_nan(ny), "NaN in random check")
      local d = dist(nx, ny, target.x, target.y)
      assert_true(approx_le(d, last, 1e-5), "Distance increased unexpectedly")
      last, reached, iters = d, r, iters + 1
    end
    assert_true(reached, "Did not reach target within 2000 frames")
  end
end

-- 2) Test move_towards reference implementation
local move_towards = require("move_towards")
do
  local x,y = 0,0
  local tx,ty = 3,4 -- dist=5
  local reached = false
  local total = 0
  while not reached and total < 10 do
    x,y,reached = move_towards(x,y,tx,ty,10,0.1) -- step=1
    total = total + 1
  end
  assert_true(reached, "move_towards failed to reach")
  assert_true(math.abs(x-tx)<1e-6 and math.abs(y-ty)<1e-6, "Did not snap exactly to target")
end

-- 3) Test spawn scheduler
local sched = require("spawn_scheduler").schedule_spawns
do
  local times = sched(5.0, 60.0, 3, 0.5, 123)
  -- expected waves ~ 0..60 every 5s -> 13 waves (including t=60) => ~39 spawns
  assert_true(#times >= 36 and #times <= 39, "Unexpected spawn count: "..#times)
  for i,t in ipairs(times) do
    assert_true(t >= 0 and t <= 60.0, "Out-of-range timestamp")
  end
  for i=2,#times do
    local delta = times[i] - times[i-1]
    assert_true(delta >= 0, "Timestamps must be sorted non-decreasing")
  end
end

print("OK: all tests passed.")
