-- buggy_spawn.lua — demonstrates common defects
-- Problems:
-- 1) e.pos might be nil; 2) division by zero at target; 3) mutates before validation
local function step_entity(e, target, dt)
  -- assume e.pos exists (bug)
  local x, y = e.pos.x, e.pos.y

  local dx, dy = target.x - x, target.y - y
  local dist = math.sqrt(dx*dx + dy*dy)

  -- normalize (risk: 0/0 when dist==0)
  local nx, ny = dx / dist, dy / dist

  -- blindly mutate (bug if dist==0, yields NaN)
  x = x + nx * e.speed * dt
  y = y + ny * e.speed * dt

  -- write back
  e.pos.x, e.pos.y = x, y
  return e.pos.x, e.pos.y, dist == 0
end

return step_entity
