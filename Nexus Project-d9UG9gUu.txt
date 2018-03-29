io = require("io")
os = require("os")
component = require("component")
term = require("term")
sides = require("sides")
colors = require("colors")
fs = require("filesystem")
event = require("event")

gpu = component.gpu
transposer = component.transposer

function resetVariables()
	chestSide = sides.top
	portalSide = sides.north
end

function checkVariables()
	if chestSide == portalSide then throwError("Variables chestSide and PortalSide are the same.") end
end

function checkChestContents()
	local list = {}
	for i = 1, transposer.getInventorySize(chestSide) do
		local slot = transposer.getStackInSlot(chestSide, i)
		if slot == nil then
			slot = {label = "Slot Open"}
		end
		slot = slot.label
		string.insert(list, tostring(slot))
	end
	return list
end

function updateButtonList()
	local itemList = checkChestContents
	
	
end

function addRect(x1,y1,x2,y2,color)
  temp = gpu.getBackground()
  gpu.setBackground(color)
  gpu.fill(x1,y1,x2-x1+1,y2-y1+1," ")
  gpu.setBackground(temp)
end

function GUI()
	
end

function updateScreen()
	
end

function update(buttonsPressed)
	buttonPressed = buttonsPressed[1]
	if buttonPressed == nil then return nil end
	transposer.transferItem(chestSide, portalSide, 1, buttonPressed, 1)
	os.sleep(10)
	transposer.transferItem(portalSide, chestSide, 1, 1, buttonPressed)
	return nil
end

function init()
	resetVariables()
	GUI()
end

function main()
	local buttonsPressed = BA.updateAll(event.pull("touch"))
	update(buttonsPressed)
end

init()
repeat
	main()
until false