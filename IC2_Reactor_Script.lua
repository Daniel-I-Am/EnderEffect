component = require("component")
os = require("os")
term = require("term")
sides = require("sides")
 
gpu = component.gpu
redstone = component.redstone
reactor = component.reactor
mfsu = component.ic2_te_mfsu

--[[Colors Tables]]--
colors = { black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000,
purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00,
lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b,
olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92,
folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c,
englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a,
lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00 }

GUIColors = {background = colors.black, textCol = colors.white, barsText = colors.black, barsForeground = colors.green, barsBackground = colors.gray, barsOutline = colors.white}

--Variables:
w = 100
h = 30
redstoneSide = sides.up --reactor is on this side from the redstone i/o

function GUI()
	gpu.setResolution(w,h)
	term.clear_()
	--draws bar outlines
	addRect(1,1,52,7,GUIColors.barsOutline)
	addRect(1,9,52,15,GUIColors.barsOutline)
	addRect(54,1,h+1,w+1,GUIColors.barsOutline)
end

function Update()
	heat = reactor.getHeat()
	maxHeat = reactor.getMaxHeat()
	EUOutput = reactor.getReactorEUOutput()
	state = reactor.isActive()
	mfsuCapacity = mfsu.getCapacity()
	mfsuEnergy = mfsu.energyStored()
	
	if energyGoal == nil then energyGoal = EUOutput end
	if energyGoal < EUOutput then energyGoal = EUOutput end
	
	heatPercentage = heat/maxHeat
	energyPercentage = mfsuEnergy/mfsuCapacity
	
	heatPixels = math.floor(heatPercentage * 50)
	energyPixels = math.floor(energyPercentage * 50)
	
	addRect(heatPixels+1,2,51,7,GUIColors.barsBackground)
	addRect(2,2,heatPixels+1,7,GUIColors.barsForeground)
	
	addRect(energyPixels+1,9,51,15,GUIColors.barsBackground)
	addRect(2,9,energyPixels+1,15,GUIColors.barsForeground)
	
	if heatPercentage>0.75 or energyPercentage>0.9 then redstone.setOutput(redstoneSide,0) end
	if heatPercentage<0.25 and energyPercentage<0.9 then redstone.setOutput(redstoneSide,15) end
end

function addRect(x1,y1,x2,y2,col)
    gpu.setBackground(col)
    gpu.set(x1,y1,x2-x1,y2-y1," ")
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

function Center(y,text)
    width, height = gpu.getResolution()
    term.setCursor((width-string.len(text))/2+1, y)
    term.write(text)
end

GUI()
while true do
	Update()
	os.sleep(0.5)
end