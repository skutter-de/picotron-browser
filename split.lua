-- split.lua
-- splits a .p64 single-file cartridge into a directory of individual files
-- usage: run from the browser folder, pass the cart name as argument
--   split podweb-browser.p64
--   split podnet_markdown_demo.p64

cd(env().path)

local raw_arg = env().argv[1]
if not raw_arg then
  print("usage: split <cartridge.p64>")
  return
end

local function unquote(s)
  return string.match(s, '^"(.*)"$') or s
end

local cart_name = unquote(pod(raw_arg))
local src = fetch(env().path .. "/" .. cart_name)

if not src or src == "" then
  print("could not read: " .. cart_name)
  return
end

local out_dir = env().path .. "/" .. cart_name .. ".dir"
mkdir(out_dir)

local current_file = nil
local current_lines = {}

local function flush()
  if current_file and #current_lines > 0 then
    local sub_dir = string.match(current_file, "^(.+)/[^/]+$")
    if sub_dir then mkdir(out_dir .. "/" .. sub_dir) end
    store(out_dir .. "/" .. current_file, table.concat(current_lines, "\n"))
    print("  wrote " .. current_file)
  end
end

for line in string.gmatch(src .. "\n", "([^\n]*)\n") do
  local fname = string.match(line, "^:: (.+)")
  if fname then
    flush()
    current_file  = fname
    current_lines = {}
  elseif current_file then
    add(current_lines, line)
  end
end
flush()

print("done -> " .. out_dir)
