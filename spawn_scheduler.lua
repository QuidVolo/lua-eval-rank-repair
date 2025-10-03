-- spawn_scheduler.lua — simple wave scheduler with jitter
-- schedule_spawns(period, duration, batch, jitter, seed) -> array of timestamps (sorted)
-- period    : seconds between waves
-- duration  : total schedule window (seconds)
-- batch     : spawns per wave
-- jitter    : +/- seconds randomization per spawn (optional, default 0)
-- seed      : optional math.randomseed for reproducibility
local function schedule_spawns(period, duration, batch, jitter, seed)
  assert(period and period > 0, "period must be > 0")
  assert(duration and duration > 0, "duration must be > 0")
  assert(batch and batch >= 1, "batch must be >= 1")
  jitter = jitter or 0
  if seed then math.randomseed(seed) end

  local out = {}
  local t = 0.0
  while t <= duration + 1e-9 do
    for i=1,batch do
      local j = jitter * (2 * math.random() - 1)  -- [-jitter, +jitter]
      local ts = t + j
      if ts >= 0 and ts <= duration then
        out[#out+1] = ts
      end
    end
    t = t + period
  end
  table.sort(out)
  return out
end

return {
  schedule_spawns = schedule_spawns
}
