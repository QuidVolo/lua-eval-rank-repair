-- fixed_spawn.lua — repaired version (pure-ish, guarded, returns reached)
local function step_entity(e, target, dt)
  -- Ensure position exists
  if not e.pos then e.pos = {x=0, y=0} end
  local x, y = e.pos.x, e.pos.y

  local dx, dy = target.x - x, target.y - y
  local dist_sq = dx*dx + dy*dy
  if dist_sq == 0 then
    -- already there
    return x, y, true
  end

  local dist = math.sqrt(dist_sq)
  local step = (e.speed or 0) * dt

  if step >= dist then
    -- snap to target and report reached
    e.pos.x, e.pos.y = target.x, target.y
    return target.x, target.y, true
  end

  local nx, ny = dx / dist, dy / dist
  local nx_step, ny_step = nx * step, ny * step

  e.pos.x = x + nx_step
  e.pos.y = y + ny_step
  return e.pos.x, e.pos.y, false
end

return step_entity
