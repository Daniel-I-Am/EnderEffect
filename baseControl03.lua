--pastebin get Jn1LvVhv /home/baseControl.lua -f; /home/baseControl.lua
do --import
  component = require("component")
  term = require("term")
  event = require("event")
  sides = require("sides")
  computer = require("computer")
  os = require("os")
  keyboard = require("keyboard")
  shell = require("shell")
  BA = require("ButtonAPI")
end

do --configure from import
  internet = require("component").internet
  screen = component.screen
  gpu = component.gpu
end
---------- TABLES -----------
colors = { black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000,
purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00,
lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b,
olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92,
folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c,
englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a,
lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00 } --doesn't this look very fucking fancy :3

listOfComponents = {
--{id, displayName, redstoneOutputSide, isInvertedSignal},
}

oddList = {}
evenList = {}
status = {}

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

-------- FUNCTIONS --------------

args, options = shell.parse(...) --grav supplied arguments and option, args are not used

function init() --initialization
  local canPass = true --if canPass == false then stop the program (end)
  for i = 1, #listOfComponents do --loop through components
    if #listOfComponents[i] < 4 then --to check if we had enough args supplied
      canPass = false --if not, then we say we cannot execute the program
      io.stderr:write("Component array number " .. i .. " is missing arguments, 4 expected, received only " .. #listOfComponents[i] .. ".\n") --debug
    end
    local comp, _ = component.get(listOfComponents[i][1]) --also check wether the components exists
    local type = "nil" --down here
    if comp ~= nil then type = component.proxy(comp).type end --well, more like down here
    if type ~= "redstone" then --if it is not the right type
      canPass = false --then we do not allow execution
      io.stderr:write("Components array number " .. i .. " is not supplied with valid ID. Received block of type " .. type .. "\n") --debug
    end
  end
  os.sleep(1)
  if not canPass then os.exit() end --check wether we allowed the program to run based on init checks
  w, h = gpu.getResolution() --otherwise get global vars for resolution
  for i = 1, #listOfComponents do --go through the list of components
    table.insert(oddList, i * 2 - 1) --and do something, I swear it *is* indeed used for something
    table.insert(evenList, i * 2) --but I cannot remember for the life of me why this is
    table.insert(status, true) --really necessary
  end
  createButtons(listOfComponents) --of course we create the buttons
  if options.c then --check supplied options, only -c right now
    clearLog() --clear the log and reset to default
  end
  fileWrite("/etc/baseControl/logs/latest.log", getTime() .. ": " .. "Base Control initialized", false) --debug
  screen.setTouchModeInverted(true) --set prefered touch mode
  for i = 1, #listOfComponents do
    status[i] = component.proxy(listOfComponents[i][1]).getOutput(listOfComponents[i][3]) > 0
    if listOfComponents[i][4] then status[i] = not status[i] end
  end
end

function clearLog() --this clears log
  os.execute("md /etc/baseControl/logs/") --makes sure the folder /etc/baseControl/logs/ exists
  os.execute("cp /etc/baseControl/logs/latest.log /etc/baseControl/logs/" .. getTime():gsub(" ", "-"):gsub(":", "-") .. ".log") --copies the current log with timestamp over
  os.execute("echo \"Base Control Log:\" > /etc/baseControl/logs/latest.log") --makes new log
end

function shutdown()
  --shouldRep = true --don't need this
  gpu.setForeground(0xffffff) --reset colors
  gpu.setBackground(0x000000)
  gpu.setResolution(gpu.maxResolution()) --reset resolution
  term.clear() --reset text on screen
  screen.setTouchModeInverted(false) --reset touch mode
  print("You've terminated Base Control") --print debug
  _, _, _, _, player = event.pull("key_up") --wait until someone releases a key (this is the only way the program can be stopped when shutdown() is called)
  fileWrite("/etc/baseControl/logs/latest.log", getTime() .. ": " .. player .." terminated Base Control", false) --write their name to file
  clearLog() --save the log
end

function getTime() --get time, this is just a pain in the ***
  page = internet.request("http://worldclockapi.com/api/jsonp/cet/now?callback=mycallback") --request page
  repeat --loop
  file = page.read() --file read
  until file ~= "" --until we have something not empty string, this will be the time
  a,b = file:find("%d+%-%d+%-%d..%d+:%d+") --I love bodging (bodging = making a temporary repair)
  c = file:sub(a, b):find("T") --yeeeeaaahhhh... it's necessary
  time = "[" .. file:sub(a, a + c - 2) .. " " .. file:sub(a + c, b) .. "]" --this mess
  return time --return the mess
end
 
function guiBorders(x,y,len,height,str) -- BORDER FUNC FOR GUI
  gpu.setBackground(Border_bg)
  gpu.fill(x,y,len,height,str)
  gpu.setBackground(Default_bg)
end
 
function fileWrite(fileLocation, str, isOverwrite)
  if isOverwrite==true then mode = "w" else mode = "a" end --get mode, 'w' overwrite or 'a' append
  f = io.open(tostring(fileLocation),mode) --open file
  f:write(tostring(str).."\n") --write text
  f:close() --close file, just good habit
end
 
function GUI() -- SETS THE GUI LAYOUT (GRAPHICAL USER INTERFACE)
  gpu.setBackground(Default_bg) --set background to Default_bg-color
  term.clear() --clear to apply color everywhere
  --w,  h = gpu.getResolution() --not necessary, already defined in init()
  guiBorders(1,1,w,1," ") --draw borders
  guiBorders(1,5,w,1," ")
  for i = 1,h do
    guiBorders(1,i,1,1," ")
    guiBorders(w,i,1,1," ")
  end
  guiBorders(1,h,w,1," ")
  gpu.setForeground(header)
  Center(3,"--[[ Base Control ]]--") --set text
end

function comma_value(n) -- credit http://richard.warburton.it
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$') --you do you, richard warburton, you do you
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right --I cannot explain this in simple comments
end --at least, not yet... I will someday, would actually have to put in effort

function centerText(str, x1, x2, y, FGCol, BGCol) --this is copied from the official danAPI.lua, pretty selfexplanatory
  if not component.isAvailable("gpu") then return end --safety
  local w,_ = gpu.getResolution()
  x1 = x1 or 1 --define undefined variables
  x2 = x2 or w
  y = y or 1
  str = str or "text"
  FGCol = FGCol or gpu.getForeground()
  BGCol = BGCol or gpu.getBackground()
  local prevFG = gpu.getForeground() --get previous color values, to reset to later on
  local prevBG = gpu.getBackground()
  local l = string.len(tostring(str)) --get length
  local center = math.floor((x1+x2)/2) --get center of string
  local startPos = math.ceil(center - (l-1)/2) --now figure out the starting position
  gpu.setForeground(FGCol) --dothe printing
  gpu.setBackground(BGCol)
  gpu.set(startPos,y,str)
  gpu.setForeground(prevFG) --reset colors
  gpu.setBackground(prevBG)
end

function Center(y, text) --the bad version of centerText()
  w, h = gpu.getResolution()
  term.setCursor((w-string.len(text))/2+1, y)
  term.write(text)
end

function createButtons(list) --create all buttons, one for on and one for off
  BA.clear()
  for i,v in ipairs(list) do
    --These couple lines are not quite clean enough for my liking, but they do work
    BA.makeButton(buttonXOff + math.floor((i-1)/3) * (buttonWidth + buttonSpacingX), buttonYOff + ((i - 1) % buttonsColumn) * (buttonHeight + buttonSpacingY), buttonWidth, buttonHeight, buttonColorButtonOn, buttonColorText, -1, -1, list[i][2])
    BA.makeButton(buttonXOff + math.floor((i-1)/3) * (buttonWidth + buttonSpacingX), buttonYOff + ((i - 1) % buttonsColumn) * (buttonHeight + buttonSpacingY), buttonWidth, buttonHeight, buttonColorButtonOff, buttonColorText, -1, -1, list[i][2])
  end
end

function displayPower()
  if not component.isAvailable("draconic_rf_storage") then return end --only continue IF there is a power ball
  draco = component.draconic_rf_storage
  do --read values
    power = draco.getEnergyStored()
    maxPower = draco.getMaxEnergyStored()
    transfer = draco.getTransferPerTick()
    powerPCT = math.floor(100000 * power/maxPower + 5)/1000
  end
  do --do stuff with values
    if transfer < 0 then isNegTransfer = true else isNegTransfer = false end
    if isNegTransfer then transferColor = colors.red else transferColor = colors.lime end
    off = 90
    if power >= 1e14 then power = tostring(power); power = power:sub(1,5) .. power:sub(-4) end
    if maxPower >= 1e14 then maxPower = tostring(maxPower); maxPower = maxPower:sub(1,5) .. maxPower:sub(-4) end
  end
  do --the actual dislay
    gpu.set(off, 6, "Power:")  
    gpu.set(off, 7, "    " .. comma_value(tostring(power)) .. " / " .. comma_value(tostring(maxPower)) .. " RF (" .. powerPCT .. "%)    ")
    gpu.set(off, 8, "Usage:")
    temp = gpu.getForeground()
    gpu.setForeground(transferColor)
    gpu.set(off, 9, string.rep(" ", w - off - 1))
    gpu.set(off, 9, "    " .. comma_value(tostring(transfer)) .. " RF/t")
    gpu.setForeground(temp)
  end
end

function drawButtons()
    for i = 1, #listOfComponents do
    if status[i] then j = 0 else j = 1 end
    BA.draw({2*i + j - 1})
  end
end

do --main code
  gpu.setResolution(150,30) --set resolution, why is this not in GUI() or init()
  init() --set base values
  GUI() --make general purpose GUI

  repeat
    drawButtons() --draws the correct buttons, only the ones for the right state
    startTime = computer.uptime() --take time for proper timer functionality
    do --execute main code
      local e,id,x,y,b,p = event.pull(1,"touch") --wait for possible touch event
      if e ~= nil then --if we touched e == "touch"
        buttonsPressed = BA.updateAll(e,id,x,y,b,p) --check which buttons we pressed, this will be button x and x+1
        buttonsPressed = {buttonsPressed[1], buttonsPressed[2]} --grab only the first two touches, so we have an array of {x, x+1}
        if buttonsPressed[1] ~= nil then --check if we actually clicked a button and not nothing
          fileWrite("/etc/baseControl/logs/latest.log", getTime() .. ": " .. p .. " toggled " .. listOfComponents[buttonsPressed[2]/2][2]) --debug
          if status[buttonsPressed[2]/2] then --check what the status is of the button
            buttonPressed = buttonsPressed[1] --if it's true then only check the on state of the button
          else --else
            buttonPressed = buttonsPressed[2] --only check the state of the off button
          end
          status[buttonsPressed[2]/2] = not status[buttonsPressed[2]/2] --toggle status of the button
          if status[buttonsPressed[2]/2] then --set rs output based on status
            out = 15
          else
            out = 0
          end
          if listOfComponents[buttonsPressed[2]/2][4] then out = 15 - out end --adjust based on isInvertedSignal
          component.proxy(listOfComponents[buttonsPressed[2]/2][1]).setOutput(listOfComponents[buttonsPressed[2]/2][3], out) --actually do the output now
        end
      end
    end
    displayPower() --show power if we have a power ball (check in function)
    repeat --make sure we actualy wait 0.5 seconds
      os.sleep(0.05)
    until computer.uptime() >= startTime + 0.5
    shouldRep = not keyboard.isControlDown() --check if we need to stop
  until shouldRep == false --if we clicked stop, stop
  shutdown() --stop
end