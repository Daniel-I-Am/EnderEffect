comp = require("component")
event = require("event")
term = require("term")
gpu = comp.gpu
BA = require("ButtonAPI")
colors = require("colors")
os = require("os")
io = require("io")
uni = require("unicode")

function fileToArray(filepath)
  array = {}
  local file = io.open(filepath,"r")
  if file~=nil then
    repeat
      line = file:read("*line")
      if line ~= nil then
        a = string.find(line,";")
        if a then
          print(string.sub(line,1,a-1)..":"..string.sub(line,a+1,-1))
          table.insert(array,string.sub(line,1,a-1))
          table.insert(array,string.sub(line,a+1,-1))
          --os.sleep(0.05)
        end
		a = nil
      end
    until line == nil
    file:close()
    return array
  else
    return {}
  end
end

pricelistCommon = fileToArray("/home/pricelistCommon.txt")
pricelistUncommon = fileToArray("/home/pricelistUncommon.txt")
pricelistRare = fileToArray("/home/pricelistRare.txt")
pricelistEpic = fileToArray("/home/pricelistEpic.txt")
pricelistLegendary = fileToArray("/home/pricelistLegendary.txt")

information = {
"--------------------------------------","",
"             INFORMATION              ","",
"--------------------------------------","",
"This is the server's pricelist.       ","",
"This list lists the lowest price you, ","",
"as a player, can sell at.             ","",
"Of course you can sell above these    ","",
"prices.                               ","",
"                                      ","",
"Use the buttons on the side           ","",
"and bottom to navigate.               ","",
"                                      ","",
"If you have any questions regarding   ","",
"this pricelist and its rules, ask     ","",
"the other players.                    ","",
"If they don't know it either, don't   ","",
"hesitate to ask a BOE member. Any     ","",
"missing items or mistakes in the list ","",
"should be reported to a BOE member.   ",""
}

list = {}
page = 0

funtion GUI()
	gpu.setResolution(60,25)
	gpu.setBackground(0x000000)
	gpu.setForeground(0xffffff)
	term.clear()
	width,height = gpu.getResolution()
	BA.clear() -- clears the buttons stored
end
	
function createButtons()
	--xOffset, yOffset, width, height, Background Color, Text Color, textXOffset, textYOffset, text
	BA.makeButton(width-21,height-3,19,3,0x808080,0xffffff,-1,-1,"Common") --1
	BA.makeButton(width-21,height-7,19,3,0x36c95e,0xffffff,-1,-1,"Uncommon") --2
	BA.makeButton(width-21,height-11,19,3,0x4283d8,0xffffff,-1,-1,"Rare") --3
	BA.makeButton(width-21,height-15,19,3,0x9c52c8,0xffffff,-1,-1,"Epic") --4
	BA.makeButton(width-21,height-19,19,3,0xdd871c,0xffffff,-1,-1,"Legendary") --5
	BA.makeButton(width-21,height-23,19,3,0xffffff,0x000000,-1,-1,"Information") --6
	BA.makeButton(8,height-3,6,3,0xffffff,0x000000,-1,-1,"next") --7
	BA.makeButton(1,height-3,6,3,0xffffff,0x000000,-1,-1,"prev") --8
	--xOff,yOff,w,h,Bcolor if -1 then transparent,Tcolor if -1 then transparent,sXOff if -1 then center,sYOff if -1 then center,str
end

function checkButtons()
  l = BA.updateAll(event.pull("touch"))
  for k,v in pairs(l) do
    buttonNumber = v
  end
  l = {}
  return buttonNumber
end

function selectList()
  buttonNumber = checkButtons()
  if buttonNumber == 1 then
    list = pricelistCommon
    page = 0
  elseif buttonNumber == 2 then
    list = pricelistUncommon
    page = 0
  elseif buttonNumber == 3 then
    list = pricelistRare
    page = 0
  elseif buttonNumber == 4 then
    list = pricelistEpic
    page = 0
  elseif buttonNumber == 5 then
    list = pricelistLegendary
    page = 0
  elseif buttonNumber == 6 then
    page = 0
    list = information
  elseif buttonNumber == 7 then
    page = page + 1
    gpu.set(1,1,tostring(page))
    if page > math.floor(#list/38) then page = 0 end
  elseif buttonNumber == 8 then
    page = page - 1
    if page < 0 then page = math.floor(#list/38) end
  else
    print("you broke it")
    buttonNumber = 1
  end
end

GUI()
createButtons()

repeat
  BA.drawAll() --Draws all buttons
  selectList() 
  term.clear()
  print("")
  for i=1+38*page,38+38*page,2 do
    if i>#list then
      print("")
    else
      gpu.set(1,(i+1)/2-19*page+1,list[i])
      gpu.set(width-24-uni.len(list[i+1]),(i+1)/2-19*page+1,list[i+1])
      --print(tostring(list[i]).." "..tostring(list[i+1]))
    end
  end
until false --forever (until true==false)