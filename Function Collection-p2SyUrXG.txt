--##################################################  Libraries
io = require("io");os = require("os");component = require("component");term = require("term");sides = require("sides");colors = require("colors");fs = require("filesystem");gpu = component.gpu

io = require("io")
os = require("os")
component = require("component")
term = require("term")
sides = require("sides")
colors = require("colors")
fs = require("filesystem")

gpu = component.gpu

--##################################################  Debug
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
 
function debugLog(str)
	fileWrite("debug.log", str, false)
end

--##################################################  GUIS

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

BA = require("ButtonAPI")
function updateButtons(list, buttonsPerColumn, buttonXSize, buttonYSize, buttonXOffset, buttonYOffset, buttonColor, textColor, buttonXSpacing, buttonYSpacing)
  BA.clear()
  local list = listToPage(list,buttonsPerColumn)
  for i = 1,#list do
    for j = 1, #list[i] do
      BA.create(buttonXOffset + (i-1) * (buttonXSpacing + buttonXSize), buttonYOffset + (j-1) * (buttonYSpacing + buttonYSize), buttonXSize, buttonYSize, buttonColor, textColor, -1, -1, tostring(list[i][j]))
    end
  end
  BA.drawAll()
end

--##################################################  File manipulation
function fileRead(fileLocation)
	local str = {}
	if fs.exists("/home/"..fileLocation) then
		f = io.open("/home/"..fileLocation, "r")
		repeat
			line = f:read("*line")
			if line ~= nil then
				table.insert(str, line)
			end
		until line == nil
	else
		throwError("File /home/"..fileLocation.." not found!")
	end
	f:close()
	f = nil
	return str
end

function fileWrite(fileLocation, str, isOverwrite)
  if isOverwrite==true then mode = "w" else mode = "a" end
  f = io.open("/home/"..fileLocation,mode)
  f:write(tostring(str).."\n")
  f:close()
end

--##################################################  Timing

function displaySleepTime(y,toSleep, txtcol, bgcol, textToShowPre, textToShowPost)
    repeat
        centerText("   " .. textToShowPre .. " " .. math.floor(toSleep/60) .. " minutes and " .. toSleep%60 .. " seconds" .. textToShowPost .. "   ", 1, w, y, txtcol, bgcol)
        toSleep = toSleep - 1
        os.sleep(1)
    until toSleep == -1
end

--##################################################  Data Manipulation
function listToPages(list,entriesPerPage)
    pageList = {}
    value = nil
    tempList = {}
   
    for i = 1,#list,entriesPerPage do
        tempList = {}
        for j = 1,entriesPerPage do
            value = table.remove(list, 1)
            table.insert(tempList, value)
        end
        table.insert(pageList, tempList)
    end
    return pageList
end

function comma_value(n) -- credit http://richard.warburton.it
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function randomDigitNoRep(lowerBound, upperBound, numberOfNumbers)
  lowerBound = lowerBound or 1
  upperBound = upperBound or 10
  numberOfNumbers = numberOfNumbers or 1
  if upperBound - lowerBound + 1 < numberOfNumbers then print("wrong size"); return nil end
  local hasBeenPicked = false
  local list = {}
  for i = 1, numberOfNumbers do
    repeat
      hasBeenPicked = false
      n = math.random(lowerBound, upperBound)
      for j = 1, #list do
        if n == list[j] then
          hasBeenPicked = true
        end
      end
    until hasBeenPicked == false
    table.insert(list, n)
  end
  return list
end

function sortList(array, mode)
  local arrayCopy = {}
  for k,v in pairs(array) do
    arrayCopy[k] = v
  end
  
  mode = mode or "a"
  if mode == "d" then
    for i = 1, #arrayCopy do
      for j = 1, #arrayCopy - i do
        local a = arrayCopy[j]
        local b = arrayCopy[j+1]
        if a < b then
          arrayCopy[j] = b
          arrayCopy[j+1] = a
        end
      end
    end
    return arrayCopy
  else
    for i = 1, #arrayCopy do
      for j = 1, #arrayCopy - i do
        local a = arrayCopy[j]
        local b = arrayCopy[j+1]
        if a > b then
          arrayCopy[j] = b
          arrayCopy[j+1] = a
        end
      end
    end
    return arrayCopy
  end
  return nil
end

function sortArray(array, mode)
  local i = 0
  local pointers = {}
  local data = {}
  local arrayCopy = {}
  for k,v in pairs(array) do
    arrayCopy[k] = v
  end
  for k,v in pairs(arrayCopy) do
    pointers[i] = k
    data[i] = v
    i = i + 1
  end
  mode = mode or "a"
  if mode == "d" then
    for i = 0, #data do
      for j = 0, #data - i - 1 do
        local a = data[j]
        local b = data[j+1]
        local c = pointers[j]
        local d = pointers[j+1]
        if a < b then
          data[j] = b
          pointers[j] = d
          data[j+1] = a
          pointers[j+1] = c
        end
      end
    end
    return pointers, data
  else
    for i = 0, #data do
      for j = 0, #data - i - 1 do
        local a = data[j]
        local b = data[j+1]
        local c = pointers[j]
        local d = pointers[j+1]
        if a > b then
          data[j] = b
          pointers[j] = d
          data[j+1] = a
          pointers[j+1] = c
        end
      end
    end
    return pointers, data
  end
  return nil
end