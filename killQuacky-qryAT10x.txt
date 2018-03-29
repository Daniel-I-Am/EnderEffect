event = require("event")
io = require("io")
os = require("os")
component = require("component")
term = require("term")
sides = require("sides")
colors = require("colors")
fs = require("filesystem")
BA = require("ButtonAPI")

gpu = component.gpu
debug = component.debug

playerToKill = "3DWafflee"
whitelistedPlayer = "Daniel_I_Am"

width = 100
height = 30
gpu.setResolution(width, height)

function genButtons()
  BA.clear()
  BA.makeButton(width-21,2,19,3,0xcccccc,0xff0000,-1,-1,"Kill")
  BA.makeButton(width-21,6,19,3,0xcccccc,0xff0000,-1,-1,"Slow Death")
end

function throwError(errorMessage)
  gpu.setResolution(gpu.maxResolution())
  gpu.setForeground(0xff0000)
  gpu.setBackground(0x000000)
  term.clear()
  print("The program ran into a serious error during execution.")
  print(errorMessage)
  gpu.setForeground(0xffffff)
  os.exit()
end

function addRect(x1,y1,x2,y2,color)
  temp = gpu.getBackground()
  gpu.setBackground(color)
  gpu.fill(x1,y1,x2-x1+1,y2-y1+1," ")
  gpu.setBackground(temp)
end

function addProgressBar(x1,y1,x2,y2,sideWidth,sideHeight,borderColor,filledBarColor,emptyBarColor,textColor,headerText,filledPercentage,isSideways,isInverted)
  isSideways = isSideways or false
  isInverted = isInverted or false
  if type(x1)~="number" then throwError("addProgressBar() argument 1 (x1) type int expected, "..type(x1).." found") end
  if type(x2)~="number" then throwError("addProgressBar() argument 3 (x2) type int expected, "..type(x2).." found") end
  if type(y1)~="number" then throwError("addProgressBar() argument 2 (y1) type int expected, "..type(y1).." found") end
  if type(y2)~="number" then throwError("addProgressBar() argument 4 (y2) type int expected, "..type(y2).." found") end
  if type(sideWidth)~="number" then throwError("addProgressBar() argument 5 (sideWidth) type int expected, "..type(sideWidth).." found") end
  if type(sideHeight)~="number" then throwError("addProgressBar() argument 6 (sideHeight) type int expected, "..type(sideHeight).." found") end
  if type(filledPercentage)~="number" then throwError("addProgressBar() argument 11 (filledPercentage) type float expected, "..type(filledPercentage).." found") end
  if filledPercentage > 1 then filledPercentage = 1 end
  if isSideways == false then
    addRect(x1,y1,x2,y2,borderColor)
    addRect(x1+sideWidth,y1+sideHeight,x2-sideWidth,y2-sideHeight,emptyBarColor)
    barSize = (y2-y1-2*sideHeight)
    pixelsFilled = math.floor(filledPercentage*barSize+0.5)
    if isInverted == false then
      addRect(x1+sideWidth,y2-sideHeight-pixelsFilled,x2-sideWidth,y2-sideHeight,filledBarColor)
    elseif isInverted == true then
      addRect(x1+sideWidth,y1+sideHeight,x2-sideWidth,y1+sideHeight+pixelsFilled,filledBarColor)
    else
      throwError("addProgressBar() argument 13 (isInverted) type boolean expected, "..type(isInverted).." found")
    end
  elseif isSideways == true then
    addRect(x1,y1,x2,y2,borderColor)
    addRect(x1+sideWidth,y1+sideHeight,x2-sideWidth,y2-sideHeight,emptyBarColor)
    barSize = (x2-x1-2*sideWidth)
    pixelsFilled = math.floor(filledPercentage*barSize+0.5)
    if isInverted == false then
      addRect(x1+sideWidth,y1+sideHeight,x1+sideWidth+pixelsFilled,y2-sideHeight,filledBarColor)
    elseif isInverted == true then
      addRect(x2-sideWidth-pixelsFilled,y1+sideHeight,x2-sideWidth,y2-sideHeight,filledBarColor)
    else
      throwError("addProgressBar() argument 13 (isInverted) type boolean expected, "..type(isInverted).." found")
    end
  else
    throwError("addProgressBar() argument 12 (isSideways) type boolean expected, "..type(isSideways).." found")
  end
  if sideHeight>0 then
    col = {f = gpu.getForeground(),b = gpu.getBackground()}
    centerX = math.ceil((x1+x2)/2)
    centerY = math.floor(y1+sideHeight/2)
    gpu.setForeground(textColor)
    gpu.setBackground(borderColor)
    gpu.set(centerX-(string.len(tostring(headerText))/2),centerY,tostring(headerText))
    gpu.setForeground(col.f)
    gpu.setBackground(col.b)
    centerX = nil
    centerY = nil
    col = nil
  end
end

function centerText(str, x1, x2, y, FGCol, BGCol)
    local w,_ = gpu.getResolution()
    x1 = x1 or 1
    x2 = x2 or w
    y = y or 1
    str = str or "text"
    FGCol = FGCol or 0xffffff
    BGCol = BGCol or 0x000000
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

function killNow(isInstant)
  isInstant = isInstant or false
  isTargetOnline = false  

  onlinePlayers = debug.getPlayers()
  for i=1, #onlinePlayers do
    if onlinePlayers[i] == playerToKill then
      isTargetOnline = true
    end
  end

  if isTargetOnline == true then
    playerData = debug.getPlayer(playerToKill)
    if isInstant then
      playerData.setHealth(0)
    else
      repeat
        health = playerData.getHealth()-1
        playerData.setHealth(health)
        addProgressBar(1,1,10,height,2,1,0xffffff,0xff0000,0x000000,0xffffff,"",health/20,false,false)
        os.sleep(delay)
      until health == 0
      os.sleep(0.5)
    end
  end
end

function main()
  BA.drawAll()
  playerData = debug.getPlayer(playerToKill)
  health = playerData.getHealth()
  if health ~= nil then healthPoints = health end
  addProgressBar(1,1,10,height,2,1,0xffffff,0xff0000,0x000000,0xffffff,"",healthPoints/20,false,false)
  l = BA.updateAll(event.pull("touch"))
  if l[1] == 1 then
    killNow(true)
  elseif l[1] == 2 then
    delay = 0.2
    killNow()
  end
end



genButtons()
repeat
  main()
until false