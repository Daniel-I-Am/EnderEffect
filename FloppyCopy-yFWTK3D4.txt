fs = require("filesystem")
os = require("os")
event = require("event")
keyboard = require("keyboard")
computer = require("computer")

normalDirList = {}

path = ...

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

if path == nil or fs.exists(path) == false then
  print("Usage: fc <path>")
else
  for element in fs.list("/mnt/") do
    table.insert(normalDirList,element)
  end

  print("Press CTRL to exit.")
  while keyboard.isControlDown() == false do
    e = event.pull(1,"component_added")
    if e ~= nil then
      for dir in fs.list("/mnt/") do
        if has_value(normalDirList,dir) == false then 
          os.execute("cp -r "..path.." /mnt/"..dir)
          computer.beep()
        end
      end
      e = nil
    end
  end
end