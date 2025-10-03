-- perf_bench.lua — micro-benchmark for move_towards variants
local best = require("move_towards")

-- naive versions for comparison
local function bad_move(x,y,tx,ty, speed, dt)
  -- ignores zero-distance guard; risk of 0/0
  local dx, dy = tx-x, ty-y
  local dist = math.sqrt(dx*dx + dy*dy)
  local nx, ny = dx/dist, dy/dist
  return x + nx*speed*dt, y + ny*speed*dt, false
end

local function ok_move(e)
  local dx, dy = e.tx - e.x, e.ty - e.y
  local dist = math.sqrt(dx*dx + dy*dy)
  if dist == 0 then return e.x, e.y, true end
  local step = math.min(e.speed*e.dt, dist)
  return e.x + dx/dist*step, e.y + dy/dist*step, step==dist
end

local function bench(fn, n)
  local t0 = os.clock()
  local x,y,tx,ty = 0,0, 400,300
  for i=1,n do
    x,y = fn(x,y,tx,ty, 240, 1/240)
  end
  return os.clock() - t0, x, y
end

local N = 200000
local t1 = bench(best, N)
local t2 = bench(bad_move, N)

print(string.format("best move_towards:   %.4fs", t1))
print(string.format("bad  move_towards:   %.4fs", t2))
