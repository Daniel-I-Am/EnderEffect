-- turbine.setInductorEngaged
component   = require("component")
turbine     = component.br_turbine
redstone    = component.redstone
event       = require("event")
gpu         = component.gpu
term        = require("term")
sides       = require("sides")
os          = require("os")

-----------------
--[[Colors Table]]--
colors = { black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000,
purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00,
lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b,
olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92,
folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c,
englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a,
lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00 }
-------------------

--[[Variables]]--
Turbine_On  = 24500
Turbine_Off = 24200
w           = 50
h           = 3
Default_bg  = colors.gray
Border_bg   = colors.white
text_col    = colors.white
status_col  = colors.black

function guiBorders(x,y,len,height,str) -- BORDER FUNC FOR GUI
  gpu.setBackground(Border_bg)
  gpu.fill(x,y,len,height,str)
  gpu.setBackground(Default_bg)
end
 
function GUI() -- SETS THE GUI LAYOUT (GRAPHICAL USER INTERFACE)
  gpu.setResolution(w,h)
  gpu.set(1,2,"Speed of turbine is currently:")
end
 
function Center(y,text) -- CENTERS TEXT  
  w, h = gpu.getResolution()
  term.setCursor((w-string.len(text))/2+1, y)
  term.write(text)
end
 
function info(title,x,y) -- Rewriting of gpu.set
  gpu.set(x,y,title)
end

function Display()
  Center(2,"Turbine")
  info("Status: ", 2, 3)
end

function Update()
  if turbine.getRotorSpeed() >= Turbine_On then
    -- Set active
    turbine.setInductorEngaged(true)
    gpu.set(1,1,"Turbine is currently on")
  elseif turbine.getRotorSpeed() <= Turbine_Off then
    -- Set offline
    turbine.setInductorEngaged(false)
    gpu.set(1,1,"Turbine is currently off")
  end
  gpu.set(1,3,tostring(math.floor(turbine.getRotorSpeed())).." RPM")
end

term.clear()
GUI()
Display()
while true do
  if redstone.getInput(sides.south) then
    Update()
  end
  os.sleep(0.1)
end