-- move_towards.lua — best-version reference used by tests
-- Returns newX, newY, reached
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
