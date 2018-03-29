comp = require("component")
event = require("event")
term = require("term")
gpu = comp.gpu
BA = require("ButtonAPI")
colors = require("colors")

pricelistCommon = {}
pricelistUncommon = {}
pricelistRare = {}
pricelistEpic = {}
pricelistLegendary = {}




gpu.setResolution(60,25)
gpu.setBackground(0x0000ff)
gpu.setForeground(0xffffff)
term.clear()
BA.clear() -- clears the buttons stored

--xOffset, yOffset, width, height, Background Color, Text Color, textXOffset, textYOffset, text
BA.makeButton(width-21,height-3,19,3,0x808080,0xffffff,-1,-1,"Common") --1
BA.makeButton(width-21,height-7,19,3,0x36c95e,0xffffff,-1,-1,"Uncommon") --2
BA.makeButton(width-21,height-11,19,3,0x4283d8,0xffffff,-1,-1,"Rare") --3
BA.makeButton(width-21,height-15,19,3,0x9c52c8,0xffffff,-1,-1,"Epic") --4
BA.makeButton(width-21,height-19,19,3,0xdd871c,0xffffff,-1,-1,"Legendary") --5
BA.makeButton(width-21,height-23,19,3,0x000000,0xffffff,-1,-1,"Information") --6
BA.makeButton(8,height-3,6,3,0xffffff,0x000000,-1,-1,"next") --7
BA.makeButton(1,height-3,6,3,0xffffff,0x000000,-1,-1,"prev") --8
--xOff,yOff,w,h,Bcolor if -1 then transparent,Tcolor if -1 then transparent,sXOff if -1 then center,sYOff if -1 then center,str

function checkButtons()
	l = BA.updateAll(event.pull("touch"))
	for k,v in pairs(l) do
		buttonNumber = v
	end
	return buttonNumber
end

function selectList()
	buttonNumber = CheckButtons()
	if buttonNumber == 1 then
		list = pricelistCommon
		page = 1
	elseif buttonNumber == 2 then
		list = pricelistUncommon
		page = 1
	elseif buttonNumber == 3 then
		list = pricelistRare
		page = 1
	elseif buttonNumber == 4 then
		list = pricelistEpic
		page = 1
	elseif buttonNumber == 5 then
		list = pricelistLegendary
		page = 1
	elseif buttonNumber == 6 then
		
	elseif buttonNumber == 7 then
	elseif buttonNumber == 8 then
	else
	end	
end

repeat
	BA.drawAll() --Draws all buttons
	selectList()
	for i=1,40,2 do
		if i>#list then
			print("NIL  NIL")
		else
			print(tostring(list[i]).." "..tostring(list[i+1]))
		end
	end
until false