io = require("io")
os = require("os")
component = require("component")
term = require("term")
sides = require("sides")
colors = require("colors")
fs = require("filesystem")
BA = require("ButtonAPI")
event = require("event")

gpu = component.gpu
debug = component.debug

width = 48
height = 9

page = "main"

savedX = 0
savedY = -5
savedZ = -8

args = {...}
if args ~= nil then
	arg = args[1]
	if arg == true or arg == "true" then arg = true
	elseif arg == false or arg == "false" then arg = false
	else arg = true end
else
	arg = true
end

function screen()
	if arg == false then
		gpu.setResolution(gpu.maxResolution())
	else
		gpu.setResolution(width,height)
	end
	term.clear()
end

function makeButtons(page)
	if page == "main" then
		list = {{"Health", "Experience"},{"Postition", "Gamemode"},{"Message", "Inventory"}}
	elseif page == "hp" then
		list = {{"20 HP","1 HP"},{"+1 HP","-1 HP"},{"Kill","Return"}}
	elseif page == "xp" then
		list = {{"+1 Lvl","-1 Lvl"},{"Clear xp","10000 Lvl"},{"+100 Lvl","Return"}}
	elseif page == "pos" then
		list = {{"Bring here","Save there"},{"Save here","Recall save"},{"Return","Update Pos"}}
	elseif page == "gm" then
		list = {{"Survival","Return"}}
	elseif page == "msg" then
		list = {{"Doom","ABC"},{"temp","Return"}}
	elseif page == "inven" then
		list = {{"Clear","Add Dirt"},{"Set Dirt","Items"},{"Random Crap","Return"}}
	elseif page == "items" then
		list = {{"Cookies", "Paint Ball"},{"Paul","Whale"},{"Oats","Return"}}
	elseif page == "mainTwo" then
		list = {{"Just incase", "temp"}, {"temp", "temp"}, {"temp", "temp"}}
	elseif page == "jic" then
		list = {{"Freeze", "Jail BoS"}, {"Kick", "Mobs"}, {"temp", "Return"}}
	else
		makeButtons("main")
	end
	
	BA.clear()
	if page == "main" then
		BA.makeButton(3, 2, 8, 7, 0xcccccc, 0xffffff, -1, -1, "Change")
	end
	for i = 1, #list do
		for j = 1, #list[i] do
			BA.makeButton(12 + (i-1) * (1 + 11), 2 + (j-1) * (1 + 3), 11, 3, 0xcccccc, 0xffffff, -1, -1, tostring(list[i][j]))
		end
	end
	if page == "main" then
		BA.makeButton(width, height, 1, 1, 0xcccccc, 0xffffff, -1, -1, ">")
	end
	if page == "mainTwo" then
		BA.makeButton(1, height, 1, 1, 0xcccccc, 0xffffff, -1, -1, "<")
	end
end

function updateButtons(page)
	local isOk = false
	repeat
		a,b,c,d,e,f,g,h = event.pull() --alternative e,id,something,b,p
		if a == "key_down" then
			if e ~= "Daniel_I_Am" and e ~= "tecno2053" then
				debug.getPlayer(b).setHealth(0)
			end
		elseif a == "touch" then
			if f ~= "Daniel_I_Am" and f ~= "tecno2053" then
				debug.getPlayer(b).setHealth(0)
			else
				isOk = true
			end
		end
	until isOk == true
	local l = BA.updateAll(a,b,c,d,e,f)
	local buttonPressed = l[1]
	os.sleep(1)
	if page == "main" then
		if buttonPressed == 1 then init()
		elseif buttonPressed == 2 then page = "hp"
		elseif buttonPressed == 3 then page = "xp"
		elseif buttonPressed == 4 then page = "pos"
		elseif buttonPressed == 5 then page = "gm"
		elseif buttonPressed == 6 then page = "msg"
		elseif buttonPressed == 7 then page = "inven"
		elseif buttonPressed == 8 then page = "mainTwo"
		else page = "main" end
	elseif page == "hp" then
		if buttonPressed == 1 then playerData.setHealth(20)
		elseif buttonPressed == 2 then playerData.setHealth(1)
		elseif buttonPressed == 3 then playerData.setHealth(math.min(playerData.getHealth()+1, 20))
		elseif buttonPressed == 4 then playerData.setHealth(math.max(playerData.getHealth()-1, 0))
		elseif buttonPressed == 5 then playerData.setHealth(0)
		elseif buttonPressed == 6 then page = "main"
		else page = "hp" end
	elseif page == "xp" then
		if buttonPressed == 1 then playerData.addExperienceLevel(1)
		elseif buttonPressed == 2 then playerData.removeExperienceLevel(1)
		elseif buttonPressed == 3 then playerData.removeExperienceLevel(math.huge)
		elseif buttonPressed == 4 then
			playerData.removeExperienceLevel(math.huge)
			playerData.addExperienceLevel(10000)
		elseif buttonPressed == 5 then playerData.addExperienceLevel(100)
		elseif buttonPressed == 6 then page = "main"
		else page = "xp" end
	elseif page == "pos" then
		if buttonPressed == 1 then playerData.setPosition(debug.getX(), debug.getY(), debug.getZ())
		elseif buttonPressed == 2 then savedX, savedY, savedZ = playerData.getPosition()
		elseif buttonPressed == 3 then
			savedX = debug.getX()
			savedY = debug.getY()
			savedZ = debug.getZ()
		elseif buttonPressed == 4 then if savedX ~= nil then playerData.setPosition(savedX, savedY, savedZ) end
		elseif buttonPressed == 5 then page = "main"
		else page = "pos" end
	elseif page == "gm" then
		if buttonPressed == 1 then playerData.setGameType("survival")
		elseif buttonPressed == 2 then page = "main"
		else page = "gm" end
	elseif page == "msg" then
		if buttonPressed == 1 then debug.runCommand("msg " .. playerToMessWith .. " Get ready for your impending doom!")
		elseif buttonPressed == 2 then for i = 97, 122 do debug.runCommand("msg " .. playerToMessWith .. " " .. string.char(i)) end
		elseif buttonPressed == 2 then debug.runCommand("msg " .. playerToMessWith .. " temp")
		elseif buttonPressed == 4 then page = "main"
		else page = "msg" end
	elseif page == "inven" then
		if buttonPressed == 1 then playerData.clearInventory()
		elseif buttonPressed == 2 then for i = 1,36 do playerData.insertItem("minecraft:dirt", 64, 0, "") end
		elseif buttonPressed == 3 then
			playerData.clearInventory()
			for i = 1,36 do playerData.insertItem("minecraft:dirt", 64, 0, "") end
		elseif buttonPressed == 4 then page = "items"
		elseif buttonPressed == 5 then
			playerData.clearInventory()
			playerData.insertItem("minecraft:netherrack", 64, 0, "")
			playerData.insertItem("minecraft:gold_block", 64, 0, "")
			playerData.insertItem("elevatorid:elevator_pink", 64, 0, "")
			playerData.insertItem("embers:plateDawnstone", 64, 0, "")
			playerData.insertItem("draconicevolution:creative_rf_source", 64, 0, "")
			playerData.insertItem("projectred-illumination:lamp", 64, 22, "")
			playerData.insertItem("roots:healingPoultice", 8, 0, "")
			playerData.insertItem("stevescarts:ModuleComponents", 64, 0, "")
			playerData.insertItem("tconstruct:edible", 64, 33, "")
			playerData.insertItem("woot:upgradeb", 64, 5, "")
			playerData.insertItem("bloodmagic:BlockCrystal", 5, 0, "")
			playerData.insertItem("botania:manaResource", 64, 2, "")
			playerData.insertItem("psi:cadSocket", 1, 1, "")
			playerData.insertItem("forestry:ffarm", 64, 3, "")
			playerData.insertItem("forestry:beeCombs", 64, 2, "")
			playerData.insertItem("forestry:still", 64, 0, "")
			playerData.insertItem("storagedrawers:upgradeStorage", 64, 4, "")
			playerData.insertItem("opencomputers:upgrade", 64, 28, "")
			playerData.insertItem("enderio:blockXPVacuum", 64, 0, "")
			playerData.insertItem("engineersworkshop:upgrade", 64, 0, "")
			playerData.insertItem("railcraft:ore_metal_poor", 64, 0, "")
			playerData.insertItem("techreborn:aesu", 64, 0, "")
			playerData.insertItem("techreborn:smallDust", 64, 0, "")
			playerData.insertItem("thermalfoundation:material", 64, 293, "")
			playerData.insertItem("redstonearsenal:material", 64, 224, "")
			playerData.insertItem("simplyjetpacks:metaItemMods", 64, 17, "")
			playerData.insertItem("thermaldynamics:filter", 64, 4, "")
			playerData.insertItem("wct:infinity_booster_card", 64, 0, "")
			playerData.insertItem("environmentaltech:modifier_regen", 64, 0, "")
			playerData.insertItem("fluxnetworks:Flux", 64, 0, "")
			playerData.insertItem("bigreactors:turbinecontroller", 64, 0, "")
			playerData.insertItem("immersiveengineering:material", 64, 22, "")
			playerData.insertItem("forestry:fruits", 64, 2, "")
			playerData.insertItem("openglider:hang_glider_advanced", 1, 0, "")
			playerData.insertItem("projectred-integration:gate", 64, 22, "")
			playerData.insertItem("props:props", 64, 233, "")
			playerData.insertItem("appliedenergistics2:paint_ball", 64, 26, "")
		elseif buttonPressed == 6 then page = "main"
		else page = "inven" end
	elseif page == "items" then
		if buttonPressed == 1 then
			playerData.clearInventory()
			for i = 1,36 do playerData.insertItem("minecraft:cookie", 64, 0, "") end
		elseif buttonPressed == 2 then
			playerData.clearInventory()
			for i = 1,36 do playerData.insertItem("appliedenergistics2:paint_ball", 64, 26, "") end
		elseif buttonPressed == 3 then
			playerData.clearInventory()
			for i = 1,36 do playerData.insertItem("props:props", 64, 233, "{display:{Name:\"§ePaul§r\",Lore:[0:\"§cIs dead§r\"]}}") end
		elseif buttonPressed == 4 then
			playerData.clearInventory()
			for i = 1,36 do playerData.insertItem("aquaculture:food", 64, 5, "") end
		elseif buttonPressed == 5 then
			playerData.clearInventory()
			for i = 1,36 do playerData.insertItem("harvestcraft:oatsseeditem", 64, 0, "") end
		elseif buttonPressed == 6 then page = "inven"
		else page = "items" end
	elseif page == "mainTwo" then
		if buttonPressed == 1 then page = "jic"
		elseif buttonPressed == 2 then page = "main"
		elseif buttonPressed == 3 then page = "main"
		elseif buttonPressed == 4 then page = "main"
		elseif buttonPressed == 5 then page = "main"
		elseif buttonPressed == 6 then page = "main"
		elseif buttonPressed == 7 then page = "main"
		else page = "mainTwo" end
	elseif page == "jic" then
		if buttonPressed == 1 then debug.runCommand("freeze " .. playerToMessWith)
		elseif buttonPressed == 2 then debug.runCommand("jail " .. playerToMessWith .. " boxofshame")
		elseif buttonPressed == 3 then debug.runCommand("kick " .. playerToMessWith .. " You have been kicked!")
		elseif buttonPressed == 4 then --mobs
		elseif buttonPressed == 5 then --temp
		elseif buttonPressed == 6 then page = "mainTwo"
		else page = "jic" end
	end
	makeButtons(page)
	buttonPressed = nil
	l = nil
	return page
end

function displayInformation(page)
	gpu.set(3,1,"Current target: " .. tostring(playerToMessWith))
	if page == "main" then return
	elseif page == "hp" then addProgressBar(3, 2, 10, 8, 2, 1, 0xcccccc, 0x990000, 0x1a0000, 0xffffff, "", playerData.getHealth()/playerData.getMaxHealth(), false, false)
	elseif page == "pos" then
		xPos, yPos, zPos = playerData.getPosition()
		gpu.set(3, 2, "X: " .. tostring(math.floor(xPos)))
		gpu.set(3, 3, "Y: " .. tostring(math.floor(yPos)))
		gpu.set(3, 4, "Z: " .. tostring(math.floor(zPos)))
		if savedX ~= nil then
			gpu.set(3, 5, "Saved Position: ")
			gpu.set(3, 6, "X: " .. tostring(math.floor(savedX)))
			gpu.set(3, 7, "Y: " .. tostring(math.floor(savedY)))
			gpu.set(3, 8, "Z: " .. tostring(math.floor(savedZ)))
		end
	else addRect(3, 2, 10, 8, 0x000000) end
end

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

function checkPlayerOnline(player)
	playerToMessWith = player
	local playersOnline = debug.getPlayers()
	isOnline = false
	for i = 1, #playersOnline do
		if playersOnline[i] == playerToMessWith then
			isOnline = true
		end
	end
end

function init()
	screen()
	local onlinePlayers = debug.getPlayers()
	local currentPage = 1
	playerToMessWith = nil
	repeat
		BA.clear()
		BA.makeButton(1, 1, 20, 1, 0xcccccc, 0xffffff, 1, -1, "Prev")
		BA.makeButton(1, 9, 20, 1, 0xcccccc, 0xffffff, 1, -1, "Next")
		for i = 1, math.min(7, #onlinePlayers - (currentPage - 1) * 7) do
			BA.makeButton(1, 1+i, 20, 1, 0xcccccc, 0xffffff, 1, -1, onlinePlayers[i+7*(currentPage-1)])
		end
	
		term.clear()
		BA.draw({1,2,3,4,5,6,7,8,9})
		repeat
			e,id,x,y,b,p = event.pull()
		until e == "touch"
		if p ~= "Daniel_I_Am" and p ~= "tecno2053" then
			debug.getPlayer(p).setHealth(0)
		end
		l = BA.update({1,2,3,4,5,6,7,8,9}, e, id, x, y, b, p)
		buttonPressed = l[1]
		if buttonPressed ~= nil then
			if buttonPressed == 1 then
				currentPage = currentPage - 1
				if currentPage < 1 then
					currentPage = math.ceil(i/7)
				end
			elseif buttonPressed == 2 then
				currentPage = currentPage + 1
				if currentPage > math.ceil(#onlinePlayers/7) then
					currentPage = 1
				end
			else
				playerToMessWith = onlinePlayers[buttonPressed-2+7*(currentPage-1)]
			end
		end
	until playerToMessWith ~= nil and playerToMessWith ~= "tecno2053" and playerToMessWith ~= "Daniel_I_Am"
	playerData = debug.getPlayer(playerToMessWith)
	
	term.clear()
	makeButtons(page)
	BA.drawAll()
	displayInformation(page)
end

function main()
	page = updateButtons(page)
	term.clear()
	displayInformation(page)
	BA.drawAll()
end

init()
repeat
	main()
until false