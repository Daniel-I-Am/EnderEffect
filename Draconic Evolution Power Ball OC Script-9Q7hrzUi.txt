component = require("component")
sides = require("sides")
term = require("term")
gpu = component.gpu

if component.draconic_rf_storage ~= nil then
  draco = component.draconic_rf_storage
  print("Core Found, Wrapped!")
  os.sleep(1)
  else
  print("Core not found..")
  os.sleep(1)
end

colors = { black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000,
            purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00,
            lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b,
            olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92,
            folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c,
            englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a,
            lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00 
            }
-------------------------

--Vars --
  Border_bg = colors.white
  Default_bg = colors.gray
  text_col = colors.white
---------

-- Resolution --
gpu.setResolution(54,7)

-------------------------
-- Functions --
function guiBorders(x,y,len,height,str)
  gpu.setBackground(Border_bg)
  gpu.fill(x,y,len,height,str)
  gpu.setBackground(Default_bg)
end

function GUI()
  gpu.setBackground(Default_bg)
  term.clear()
  w,  h = gpu.getResolution()
  guiBorders(1,1,w,1," ")
    for i = 1,h do
     -- guiBorders(1,i,1,1," ")
     -- guiBorders(w,i,1,1," ")
    end
  guiBorders(1,h,w,1," ")
  gpu.setForeground(text_col)
end

function Center(y,text)
    w, h = gpu.getResolution()
    term.setCursor((w-string.len(text))/2+1, y)
    term.write(text)
end

function comma_value(n) -- credit http://richard.warburton.it
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function Disp()
  Center(2,"POWER STORAGE")
  cut = string.len(tostring(current))
  gpu.set(2,3,"Stored....: ")
  if cap =="∞" then
    Center(4,"   "..comma_value(string.format("%.i",current)) .."/∞RF")
  else
    Center(4,"   "..comma_value(string.format("%.i",current)) .." /"..comma_value(string.format("%.i",cap)).." RF  ("..string.format("%.i",currentP).."%)    ")
  end
  gpu.set(2,5, "Usage.....: ")
    OldCurrent = current
    os.sleep(1)
    Center(6,"                             ")
    Current = draco.getEnergyStored()
      if Current >= OldCurrent then
        gpu.setForeground(colors.lime)
        Center(6,"+"..comma_value(string.format("%.f", ((Current-OldCurrent)/20))).. " RF/t ")
        gpu.setForeground(text_col)
      else --if Current < OldCurrent then
        gpu.setForeground(colors.red)
        Center(6,comma_value(string.format("%.f",((Current-OldCurrent)/20))) .. " RF/t ")
        gpu.setForeground(text_col)
      end
end

GUI()

while true do
  current = draco.getEnergyStored()

  cap = draco.getMaxEnergyStored()
  if cap>3000000000000 then
    cap = "∞"
  else
    currentP = math.floor(current/cap*100)
  end
  Disp()
end