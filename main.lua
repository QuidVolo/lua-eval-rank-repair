-- main.lua — toggle-safe harness (B to switch modules)
local current_module = "fixed_spawn"
local step_entity

local function load_step()
  -- clear both so Love re-reads the file
  package.loaded["fixed_spawn"] = nil
  package.loaded["buggy_spawn"]  = nil
  step_entity = require(current_module)
end

local function set_module(name)
  current_module = name
  load_step()
end

local e, target, reached

local function reset_move()
  e = { pos = {x = 100, y = 100}, speed = 120 }
  target = { x = 520, y = 320 }
  reached = false
end

function love.load()
  love.window.setTitle("Lua Rank & Repair — Harness")
  love.window.setMode(720, 420, {resizable=false})
  love.graphics.setFont(love.graphics.newFont(12))
  set_module("fixed_spawn")
  reset_move()
end

function love.keypressed(key, scancode)
  if key == "space" then
    reset_move()
  elseif key == "r" then
    target.x, target.y = math.random(60, 680), math.random(60, 380)
    reached = false
  elseif key == "b" or scancode == "b" then
    if current_module == "fixed_spawn" then set_module("buggy_spawn") else set_module("fixed_spawn") end
  end
end

function love.update(dt)
  if not reached then
    e.pos.x, e.pos.y, reached = step_entity(e, target, dt)
  end
end

function love.draw()
  love.graphics.setColor(1,1,1,0.9)
  love.graphics.print(("SPACE: reset   R: new target   B: toggle   Module: %s.lua"):format(current_module), 10, 10)

  -- distance readout + epsilon ring
  local dx,dy = target.x - e.pos.x, target.y - e.pos.y
  local d = math.sqrt(dx*dx + dy*dy)
  love.graphics.print(("Entity:(%.1f, %.1f)  Target:(%.1f, %.1f)  Distance=%.2f  Reached=%s")
                      :format(e.pos.x, e.pos.y, target.x, target.y, d, tostring(reached)), 10, 28)

  love.graphics.setColor(1,0,0,1); love.graphics.circle("fill", target.x, target.y, 6)
  love.graphics.setColor(1,0,0,0.25); love.graphics.circle("line", target.x, target.y, 8)

  love.graphics.setColor(0,1,0,1); love.graphics.circle("fill", e.pos.x, e.pos.y, 6)
  love.graphics.setColor(1,1,1,0.2); love.graphics.line(e.pos.x, e.pos.y, target.x, target.y)
end
