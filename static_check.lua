-- static_check.lua — toy linter: detect global writes and risky patterns
-- Usage: lua static_check.lua file1.lua [file2.lua ...]
local function scan(path)
  local f = assert(io.open(path, "r"))
  local src = f:read("*a"); f:close()
  local warnings = {}

  -- 1) Global assignment pattern: start-of-line bare name = (very naive)
  for ln, line in ipairs( (function(s) local t = {}; for l in s:gmatch("([^\n]*)\n?") do t[#t+1]=l end; return t end)(src) ) do
    if line:match("^%s*[a-zA-Z_][%w_]*%s*=") and not line:match("^%s*local%s") then
      table.insert(warnings, {ln=ln, msg="Possible global assignment: "..line})
    end
  end

  -- 2) Division by variable 'dist' without guard (heuristic)
  if src:match("/%s*dist[^%w_]") and not src:match("if%s+dist%s*==%s*0") then
    table.insert(warnings, {ln=0, msg="Potential division by zero on 'dist' without guard"})
  end

  return warnings
end

local any = false
for i=1, #arg do
  any = true
  local path = arg[i]
  local ws = scan(path)
  for _,w in ipairs(ws) do
    print(string.format("[%s:%d] %s", path, w.ln, w.msg))
  end
end
if not any then
  print("Usage: lua static_check.lua file1.lua [file2.lua ...]")
end
