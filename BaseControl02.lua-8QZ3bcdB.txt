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
BA = require("ButtonAPI")
 
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

buttonXOff = 10
buttonYOff = 10
buttonWidth = 21
buttonHeight = 3
buttonSpacingX = 5
buttonSpacingY = 3
buttonColorButtonOn = colors.lime
buttonColorButtonOff = colors.red
buttonColorText = colors.black
buttonsColumn = 3

listOfComponents = {
--{id, displayName, redstoneOutputSide, isInvertedSignal},
  {"d9eb04c1-7556-4a56-a8c5-ee5cf1116d1a", "Void Miner", sides.north, true},
  {"d9ecdcd0-b816-4da2-a6ad-3428e60955ea", "Applied Energistics", sides.north, false},
  {"d9eb04c1-7556-4a56-a8c5-ee5cf1116d1a", "Resource Miner", sides.east, true}
}

oddList = {}
evenList = {}
status = {}

-------- FUNCTIONS --------------

args, options = shell.parse(...)

function init()
  for i = 1, #listOfComponents do
    local canPass = true
    if #listOfComponents[i] < 4 then
      canPass = false
      io.stderr:write("Component array number " .. i .. " is missing arguments, 4 expected, received only " .. #listOfComponents[i] .. ".")
    end
    if not canPass then os.exit() end
  end
  w, h = gpu.getResolution()
  for i = 1, #listOfComponents do
    table.insert(oddList, i * 2 - 1)
    table.insert(evenList, i * 2)
    table.insert(status, true)
  end
  createButtons(listOfComponents)
  if options.c then
    os.execute("/home/ClearLog.lua")
  end
  fileWrite("/etc/output.log", getTime() .. ": " .. "Base Control initialized", false)
  screen.setTouchModeInverted(true)
end

function shutdown()
  shouldRep = true
  gpu.setForeground(0xffffff)
  gpu.setBackground(0x000000)
  gpu.setResolution(gpu.maxResolution())
  term.clear()
  screen.setTouchModeInverted(false)
  print("You've terminated Base Control")
  _, _, _, _, player = event.pull("key_up")
  fileWrite("/etc/output.log", getTime() .. ": " .. player .." terminated Base Control", false)
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
 
function guiBorders(x,y,len,height,str) -- BORDER FUNC FOR GUI
  gpu.setBackground(Border_bg)
  gpu.fill(x,y,len,height,str)
  gpu.setBackground(Default_bg)
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

function centerText(str, x1, x2, y, FGCol, BGCol)
    if not component.isAvailable("gpu") then return end
    local w,_ = gpu.getResolution()
    x1 = x1 or 1
    x2 = x2 or w
    y = y or 1
    str = str or "text"
    FGCol = FGCol or gpu.getForeground()
    BGCol = BGCol or gpu.getBackground()
    local prevFG = gpu.getForeground()
    local prevBG = gpu.getBackground()
    local l = string.len(tostring(str))
    local center = math.floor((x1+x2)/2)
    local startPos = math.ceil(center - (l-1)/2)
    gpu.setForeground(FGCol)
    gpu.setBackground(BGCol)
    gpu.set(startPos,y,str)
    gpu.setForeground(prevFG)
    gpu.setBackground(prevBG)
end

function Center(y, text)
  w, h = gpu.getResolution()
  term.setCursor((w-string.len(text))/2+1, y)
  term.write(text)
end

function createButtons(list)
  BA.clear()
  for i,v in ipairs(list) do
    BA.makeButton(buttonXOff + math.floor((i-1)/3) * (buttonWidth + buttonSpacingX), buttonYOff + ((i - 1) % buttonsColumn) * (buttonHeight + buttonSpacingY), buttonWidth, buttonHeight, buttonColorButtonOn, buttonColorText, -1, -1, list[i][2])
    BA.makeButton(buttonXOff + math.floor((i-1)/3) * (buttonWidth + buttonSpacingX), buttonYOff + ((i - 1) % buttonsColumn) * (buttonHeight + buttonSpacingY), buttonWidth, buttonHeight, buttonColorButtonOff, buttonColorText, -1, -1, list[i][2])
  end
end

function displayPower()
  power = draco.getEnergyStored()
  maxPower = draco.getMaxEnergyStored()
  transfer = draco.getTransferPerTick()
  powerPCT = math.floor(1000 * power/maxPower + 5)/10
  if transfer < 0 then isNegTransfer = true else isNegTransfer = false end
  if isNegTransfer then transferColor = colors.red else transferColor = colors.lime end
  off = 90
  gpu.set(off, 6, "Power:")  
  gpu.set(off, 7, "    " .. comma_value(tostring(power)) .. " / " .. comma_value(tostring(maxPower)) .. " RF (" .. powerPCT .. "%)    ")
  gpu.set(off, 8, "Usage:")
  temp = gpu.getForeground()
  gpu.setForeground(transferColor)
  gpu.set(off, 9, "    " .. comma_value(tostring(transfer)) .. " RF/t    ")
  gpu.setForeground(temp)
end

gpu.setResolution(150,30)
init()
GUI()

repeat
  for i = 1, #listOfComponents do
    if status[i] then j = 0 else j = 1 end
    BA.draw({2*i + j - 1})
  end
  startTime = computer.uptime()
    
    --execute main code
    local e,id,x,y,b,p = event.pull(1,"touch")
    if e ~= nil then
      --if we pushed a button
      buttonsPressed = BA.updateAll(e,id,x,y,b,p)
      buttonsPressed = {buttonsPressed[1], buttonsPressed[2]}
      if buttonsPressed[1] ~= nil then
        fileWrite("/etc/output.log", getTime() .. ": " .. p .. " toggled " .. listOfComponents[buttonsPressed[2]/2][2])
        if status[buttonsPressed[2]/2] then
          buttonPressed = buttonsPressed[1]
        else
          buttonPressed = buttonsPressed[2]
        end
        status[buttonsPressed[2]/2] = not status[buttonsPressed[2]/2]
        if status[buttonsPressed[2]/2] then
          out = 15
        else
          out = 0
        end
        if listOfComponents[buttonsPressed[2]/2][4] then out = 15 - out end
        component.proxy(listOfComponents[buttonsPressed[2]/2][1]).setOutput(listOfComponents[buttonsPressed[2]/2][3], out)
      end
    end
  displayPower()
  repeat
    os.sleep(0.05)
  until computer.uptime() >= startTime + 0.5
  shouldRep = not keyboard.isControlDown()
until shouldRep == false
shutdown()