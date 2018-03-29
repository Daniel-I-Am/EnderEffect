component = require("component")
term = require("term")
gpu = component.gpu
event = require("event")
sides = require("sides")
computer = require("computer")
os = require("os")
draco = component.draconic_rf_storage
screen = component.screen
keyboard = require("keyboard")
shell = require("shell")

---------- Redstone Signals -----

VoidMiner = component.proxy(component.get("d9eb04c1-7556-4a56-a8c5-ee5cf1116d1a"))
AE = component.proxy(component.get("d9ecdcd0-b816-4da2-a6ad-3428e60955ea"))
ResourceMiner = component.proxy(component.get("d9eb04c1-7556-4a56-a8c5-ee5cf1116d1a")) --b9222075-1f93-4bed-ac1a-c2901f6582f7"))

---------- TABLES -----------
colors = { black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000,
purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00,
lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b,
olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92,
folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c,
englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a,
lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00 } --doesn't this look very fucking fancy :3

------- VARIABLES -------------

Border_bg = colors.diamond
Default_bg = colors.gray
text_col = colors.blue
status_col = colors.black
barBack = colors.black
barFill = colors.white
header = colors.orange
Applied = true
VoidMine = true
Resource = true

--Side = sides.east

-------- FUNCTIONS --------------

args, options = shell.parse(...)

function guiBorders(x,y,len,height,str) -- BORDER FUNC FOR GUI
  gpu.setBackground(Border_bg)
  gpu.fill(x,y,len,height,str)
  gpu.setBackground(Default_bg)
end

function init()
  fileWrite("/etc/output.log", getTime() .. ": " .. "Base Control initialized", false)
  screen.setTouchModeInverted(true)
  prevApplied = nil
  prevVoidMine = nil
  prevResource = nil
  if options.c then
    os.execute("/home/ClearLog.lua")
  end
end

function getTime()
  internet = require("component").internet
  page = internet.request("http://worldclockapi.com/api/jsonp/cet/now?callback=mycallback")
  repeat
  file = page.read()
  until file ~= ""
  a,b = file:find("%d+%-%d+%-%d..%d+:%d+")
  c = file:sub(a, b):find("T")
  time = "[" .. file:sub(a, a + c - 2) .. " " .. file:sub(a + c, b) .. "]"
  return time 
end

function fileWrite(fileLocation, str, isOverwrite)
  if isOverwrite==true then mode = "w" else mode = "a" end
  f = io.open(tostring(fileLocation),mode)
  f:write(tostring(str).."\n")
  f:close()
end

function GUI() -- SETS THE GUI LAYOUT (GRAPHICAL USER INTERFACE)
  gpu.setBackground(Default_bg)
  term.clear()
  w,  h = gpu.getResolution()
  guiBorders(1,1,w,1," ")
  guiBorders(1,5,w,1," ")
    for i = 1,h do
      guiBorders(1,i,1,1," ")
      guiBorders(w,i,1,1," ")
    end
    for i = 5,h do
      --guiBorders(7,i,1,5," ")
    end
  for i = 5,h do
    --guiBorders(w-6, i,1,5," ")
  end
  guiBorders(1,h,w,1," ")
  gpu.setForeground(header)
  Center(3,"--[[ Base Control ]]--")
end

function comma_value(n) -- credit http://richard.warburton.it
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end


function Center(y, text)
  w, h = gpu.getResolution()
  term.setCursor((w-string.len(text))/2+1, y)
  term.write(text)
end

function addButton(x, y, col,text)
  leng = string.len(text)
  gpu.setBackground(col)
  gpu.fill(x, y, (leng + 2), 3," ")
  gpu.setForeground(status_col)
  gpu.set(x+1, y+1, text)
  gpu.setBackground(Default_bg)
end

function infoUpdate(y, text) -- Text for function UPDATE
  w, h = gpu.getResolution()
  place = (w-string.len(text))-2
  gpu.set(place, y, text)
end

function detect(player)
  if Applied == true then
    addButton(10,10, colors.lime, "Applied Energistics")
    if prevApplied == false and player ~= nil then
      fileWrite("/etc/output.log", getTime() .. ": " .. player .. " enabled Applied", false)
      AE.setOutput(sides.north, 15)
    end
    prevApplied = Applied
  elseif Applied == false then
    addButton(10,10, colors.red  ,"Applied Energistics")
    if prevApplied == true and player ~= nil then
      fileWrite("/etc/output.log", getTime() .. ": " .. player .. " disabled Applied", false)
      AE.setOutput(sides.north, 0)
    end
    prevApplied = Applied
  end
 
  if VoidMine == true then
    addButton(10, 15, colors.lime,"Void Miner         ")
    if prevVoidMine == false and player ~= nil then
      fileWrite("/etc/output.log", getTime() .. ": " .. player .. " enabled Void Miner", false)
      VoidMiner.setOutput(sides.north, 0)
    end
    prevVoidMine = VoidMine
  elseif VoidMine == false then
    addButton(10,15, colors.red, "Void Miner         ")
    if prevVoidMine == true and player ~= nil then
      fileWrite("/etc/output.log", getTime() .. ": " .. player .. " disabled Void Miner", false)
      VoidMiner.setOutput(sides.north, 15)
    end
    prevVoidMine = VoidMine
  end
 
  if Resource == true then
    addButton(10,20, colors.lime, "Resource Miner     ")
    if prevResource == false and player ~= nil then
      fileWrite("/etc/output.log", getTime() .. ": " .. player .. " enabled Resource", false)
      ResourceMiner.setOutput(sides.east, 0)
    end
    prevResource = Resource
  elseif Resource == false then
    addButton(10,20, colors.red, "Resource Miner     ")
    if prevResource == true and player ~= nil then
      fileWrite("/etc/output.log", getTime() .. ": " .. player .. " disabled Resource", false)
      ResourceMiner.setOutput(sides.east, 15)
    end
    prevResource = Resource
  end
end

function Toggle()
    if x >= 10 and x <= 28 and y >= 10 and y <= 13 then
      if Applied == true then
        Applied = false
    elseif Applied == false then
        Applied = true
        
      end
    end

    if x >= 10 and x <= 28 and y >= 15 and y <= 17 then
      if VoidMine == true then
        VoidMine = false
      elseif VoidMine == false then
        VoidMine = true
      end
    end -- Void
    
    if x >= 10 and x <= 28 and y>= 20 and y <= 23 then
      if Resource == true then
        Resource = false
        elseif Resource == false then
        Resource = true
      end
    end   -- Resource
end

function powerDisp()
  cap = draco.getMaxEnergyStored()
  capP = math.floor(cap/cap*100)

  infoUpdate(6, "Power:                                       ")
  --[[if draco.getMaxEnergyStored() > 2140000000000 then
      cap = tostring("∞")
    else
      cap = comma_value(tostring(draco.getMaxEnergyStored()))
    end
  --]]
  infoUpdate(7, comma_value(string.format("%.i",current)) .." / ".. comma_value(string.format("%.f", (cap))).." RF  ")

  infoUpdate(8, "Usage:                                       ")
  
  OldCurrent = current
  
  Current = draco.getEnergyStored()
  
  if Current > OldCurrent then
    gpu.setForeground(colors.lime)
    infoUpdate(9,"      +"..comma_value(string.format("%.f", ((Current-OldCurrent)/20))).. " RF/t    ")
    gpu.setForeground(colors.white)
  elseif Current < OldCurrent then
    gpu.setForeground(colors.red)
    infoUpdate(9,"       "..comma_value(string.format("%.f",((Current-OldCurrent)/20))) .. " RF/t   ")
    gpu.setForeground(colors.white)
  end
end

gpu.setResolution(150,30)
init()
GUI()

while true do
  current = draco.getEnergyStored()
  OldCurrent = current
  startTime = computer.uptime()
  
  _,_,x,y,_,player = event.pull(1,"touch")
  
  if x~=nil and y~= nil then
    Toggle()
  end
  detect(player)

  gpu.setForeground(colors.white)
  powerDisp()
  if keyboard.isControlDown() then break end
  
  while computer.uptime() < startTime + 1 do
    os.sleep(0.05)
  end
end
gpu.setForeground(0xffffff)
gpu.setBackground(0x000000)
gpu.setResolution(gpu.maxResolution())
term.clear()
screen.setTouchModeInverted(false)
print("You've terminated Base Control")
_, _, _, _, player = event.pull("key_up")
fileWrite("/etc/output.log", getTime() .. ": " .. player .." terminated Base Control", false)