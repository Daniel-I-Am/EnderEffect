component = require("component")
os = require("os")
term = require("term")
sides = require("sides")
keyboard = require("keyboard")

gpu = component.gpu
redstone = component.redstone
--debug = component.debug
inven = component.transposer
filesystem = component.filesystem

--[[Explanation
//This program does nothing more than count items in a chest, display stuff on a screen and set a redstone signal if a certain condition has been met.
//This program requires one transposer on the OC network, a redstone card and the normal stuff (cpu, gpu, etc...)
//In the function inventoryCheck() there are for sets of itemTotal = itemTotal + slotCheck(stuff) -> uncomment all the directions you want to use.
]]--

--[[Colors Table]]--
colors = { black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000,
purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00,
lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b,
olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92,
folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c,
englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a,
lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00 }

--[[Custom tables]]--
title ={FGCol = colors.purple, BGCol = colors.lemon}
plainText = {FGCol = colors.black, BGCol = colors.white}
rectangles = {base = colors.lemon, center = colors.white, progressFG = colors.purple, progressBG = colors.black}

--Variables

args = {...}

itemName          = nil              --Items to request from the community -- Look in HELPME()
itemCount         = nil              --amount to request from the community -- ^
primarySide       = sides.east       --make sure this side has an inventory!!!!!
redstoneOutput    = sides.top        --Redstone signal will be outputed on this side
progressBar_col   = colors.purple    --Color of the progressbar
progressBarBG_col = colors.black     --Background color of the progressbar (the empty part)
BG_col            = colors.lemon     --Background color of the screen
FG_col            = colors.white     --foreground color of the screen
Title_col         = colors.purple    --color of all text labeled with title
Text_col          = colors.red       --color of all normal text
w                 = 70               --width of monitor in characters
h                 = 20               --height of monitor in characters

function GUI()
  gpu.setResolution(w, h)
  addRect(1,1,w,h,rectangles.base)

  addTextCentered(1,title.FGCol,title.BGCol,"COMMUNITY OBJECTIVE")
  addTextCentered(2,title.FGCol,title.BGCol,"Work together to complete the goal")
  addTextCentered(3,title.FGCol,title.BGCol,"Once complete everyone online will be rewarded!") 

  addTextCentered(9,plainText.FGCol,plainText.BGCol,"Todays Objective:")  
  addRect(6,9,w-5,18,rectangles.center)
  
  addTextCentered(11,plainText.FGCol,plainText.BGCol,"Todays goal is:")
  addTextCentered(12,plainText.FGCol,plainText.BGCol,"Submit "..itemCount.." "..itemName.." in our community chest")
  
  addRect(16,14,56,16,rectangles.progressBG)
end

--This is a comment Dan doesn't understand these lol
--why would I use those? The code that is down here \/ was all written without access to a computer.... no mistakes in it (no comments needed) xD

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
    pixelsFilled = math.floor(filledPercentage*barSize)
  if pixelsFilled >0 then
      if isInverted == false then
        addRect(x1+sideWidth,y2-sideHeight-pixelsFilled,x2-sideWidth,y2-sideHeight,filledBarColor)
      elseif isInverted == true then
        addRect(x1+sideWidth,y1+sideHeight,x2-sideWidth,y1+sideHeight+pixelsFilled,filledBarColor)
      else
        throwError("addProgressBar() argument 13 (isInverted) type boolean expected, "..type(isInverted).." found")
      end
  end
  elseif isSideways == true then
    addRect(x1,y1,x2,y2,borderColor)
    addRect(x1+sideWidth,y1+sideHeight,x2-sideWidth,y2-sideHeight,emptyBarColor)
    barSize = (x2-x1-2*sideWidth)
    pixelsFilled = math.floor(filledPercentage*barSize)
  if pixelsFilled >0 then
    if isInverted == false then
      addRect(x1+sideWidth,y1+sideHeight,x1+sideWidth+pixelsFilled,y2-sideHeight,filledBarColor)
    elseif isInverted == true then
      addRect(x2-sideWidth-pixelsFilled,y1+sideHeight,x2-sideWidth,y2-sideHeight,filledBarColor)
    else
      throwError("addProgressBar() argument 13 (isInverted) type boolean expected, "..type(isInverted).." found")
    end
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

function throwError(errorMessage)
  gpu.setResolution(gpu.maxResolution())
  gpu.setForeground(0xff0000)
  gpu.setBackground(0x000000)
  os.sleep(0.1)
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

function screen(percentage)
  gpu.setForeground(Text_col)
  gpu.setBackground(FG_col)
  Center(17,"     Amount: ".. itemTotal .." / ".. itemCount.."     ")
  addProgressBar(16,14,56,16,0,0,0xff0000,rectangles.progressFG,rectangles.progressBG,0xff0000,"Should not matter what I put here",percentage,true,false)
end

function addText(x,y,FGCol,BGCol,str)
  gpu.setForeground(FGCol)
  gpu.setBackground(BGCol)
  gpu.set(x,y,str)
end

function addTextCentered(y,FGCol,BGCol,str)
  gpu.setForeground(FGCol)
  gpu.setBackground(BGCol)
  Center(y,str)
end

function inventoryCheck()
  itemTotal = 0
  for i=1, inven.getInventorySize(primarySide) do
    itemTotal = itemTotal + slotCheck(primarySide, i)
  end
end

function slotCheck(side, slot)
  contents = inven.getStackInSlot(side,slot)
  if contents == nil then
    return 0
  else
    contents = contents.size
    return contents
  end
end

function Center(y,text)
    width, height = gpu.getResolution()
    term.setCursor((width-string.len(text))/2+1, y)
    term.write(text)
end

function HELPME()
  if not args[1] then --Check if arguments are included
    term.clear()
    print("Usage: CommunityGoals <Amount>") --gives guide on how to use the arguments
    os.exit()  --stops program
  elseif args[1] then  --does have argument
    itemCount = tonumber(args[1])  --and second to number (itemCount)
    term.clear()
    for i=1,inven.getInventorySize(primarySide) do
      if inven.getStackInSlot(primarySide,i)~= nil then
        itemName = inven.getStackInSlot(primarySide,i).label
      end
    end
    GUI()  --initial GUI setup
  end  
end

if itemCount == nil then
  itemCount = 0
end

if itemName == nil then
  itemName = "Missing"
end

HELPME()
while true do
  inventoryCheck()
  os.sleep(1)
  screen(itemTotal/itemCount)
  if keyboard.isKeyDown(keyboard.keys.w) and keyboard.isControlDown() then throwError("stopped by user") end
  if (itemTotal/itemCount)>=1 then redstone.setOutput(redstoneOutput,15) else redstone.setOutput(redstoneOutput,0) end
end