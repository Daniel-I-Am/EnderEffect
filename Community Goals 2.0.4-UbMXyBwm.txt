transposer = {"b19","324","044","330"}
redstoneFlush = "6fb"
outputRedstoneIOs = {"f5f", "395", "6c6", "0d3", "ce1"}

component = require("component")
sides = require("sides")
term = require("term")
fs = require("filesystem")
event = require("event")
os = require("os")
io = require("io")

gpu = component.gpu
internet = component.internet
keyboard = component.keyboard

transposer = {component.proxy(component.get(transposer[1])),component.proxy(component.get(transposer[2])),component.proxy(component.get(transposer[3])),component.proxy(component.get(transposer[4]))}
outputRedstoneIOs = {component.proxy(component.get(outputRedstoneIOs[1])),component.proxy(component.get(outputRedstoneIOs[2])),component.proxy(component.get(outputRedstoneIOs[3])),component.proxy(component.get(outputRedstoneIOs[4])), component.proxy(component.get(outputRedstoneIOs[5]))}
width = 100
height = 30
gpu.setResolution(width, height)

colorTable = {
	uncommon = {
		PrimaryCol = 0x36c95e,
		SecondaryCol = 0x1b642f,
	textCol = 0xffffff,
	progressFilled = 0x00ff00,
	progressEmpty = 0x000000
	},
	rare = {
		SecondaryCol = 0x4283d8,
		PrimaryCol = 0x21416c,
	textCol = 0xffffff,
	progressFilled = 0x0000ff,
	progressEmpty = 0x000000
	},
	epic = {
		SecondaryCol = 0x9c52c8,
		PrimaryCol = 0x4e2964,
	textCol = 0xffffff,
	progressFilled = 0xcc66ff,
	progressEmpty = 0x000000
	},
	legendary = {
		SecondaryCol = 0xdd871c,
		PrimaryCol = 0x6e430e,
	textCol = 0xffffff,
	progressFilled = 0xff9933,
	progressEmpty = 0x000000
	}
}

--variables
currentTier = 1
subObjective = 1
link = "http://www.endercompanies.com/time.php"
dataFile = "data.txt"
multiplier = 1
redstoneFlushSide = sides.down
redstoneOutputSide = sides.east
goalCompletionTime = 3600 --to solve
inbetweenGoalTime = 7200 --completed a t4
betweenGoalTime = 300 --when completed

--completion at:
completionTier1 = 6
completionTier2 = 4
completionTier3 = 2
completionTier4 = 1

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

function throwError(errorMessage)
	errorMessage = errorMessage or "Unknown Error"
	gpu.setResolution(gpu.maxResolution())
	gpu.setForeground(0xff0000)
	gpu.setBackground(0x000000)
	term.clear()
	print("The program ran into a serious error during execution.")
	print(errorMessage)
	gpu.setForeground(0xffffff)
	os.exit()
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

function completedObjective()
	outputRedstoneIOs[currentTier].setOutput(redstoneOutputSide, 15)
	os.sleep(1)
	outputRedstoneIOs[currentTier].setOutput(redstoneOutputSide, 0)	
	if currentTier == 1 then
		if subObjective >= completionTier1 then
			subObjective = 1
			currentTier = 2
		else
			subObjective = subObjective + 1
		end
	elseif currentTier == 2 then
		if subObjective >= completionTier2 then
			subObjective = 1
			currentTier = 3
		else
			subObjective = subObjective + 1
		end
	elseif currentTier == 3 then
		if subObjective >= completionTier3 then
			subObjective = 1
			currentTier = 4
		else
			subObjective = subObjective + 1
		end
	elseif currentTier == 4 then
		if subObjective >= completionTier4 then
			finishedObjective()
		else
			subObjective = subObjective + 1
		end
	end
--	multiplier = 2 ^ (currentTier - 1)
  if currentTier == 1 then multiplier = 0.5 + completionData
  elseif currentTier == 2 then multiplier = 2 + completionData
  elseif currentTier == 3 then multiplier = 6 + completionData * 2
  else multiplier = 40 + completionData * 4
end
end

function getTime()
	page = internet.request(link)
	page.read()
	local current = page.read()
	local formattedTime = {}
	local currentDate = string.sub(current, 1,string.find(current, ", ")-1)
	local currentTime = string.sub(current, string.find(current, ", ")+2)
	local currentDay = string.sub(current, 1,string.find(currentDate, " ")-1)
	if currentDay == "Mon" then currentDay = 1 elseif currentDay == "Tue" then currentDay = 2 elseif currentDay == "Wed" then currentDay = 3 elseif currentDay == "Thu" then currentDay = 4 elseif currentDay == "Fri" then currentDay = 5 elseif currentDay == "Sat" then currentDay = 6 elseif currentDay == "Sun" then currentDay = 7 end 
	local currentHour = string.sub(currentTime, string.find(currentTime, " ")+1,string.find(currentTime, ":")-1)
	local currentMinute = string.sub(string.sub(string.sub(currentTime, string.find(currentTime, " ")+1),string.find(string.sub(currentTime, string.find(currentTime, " ")+1), ":")+1),1,string.find(string.sub(string.sub(currentTime, string.find(currentTime, " ")+1),string.find(string.sub(currentTime, string.find(currentTime, " ")+1), ":")+1)," ")-1)
	return {tonumber(currentDay), tonumber(currentHour), tonumber(currentMinute)}
end

function addTimeToTime(currentTime, deltaTime)
	day = currentTime[1]
	hour = currentTime[2]
	minute = currentTime[3]
	local minute = minute + deltaTime
	local hour = hour + math.floor(minute/60)
	local day = day + math.floor(hour/24)
	local minute = minute%60
	local hour = hour%24
	return {day, hour, minute}
end

function getItems()
	local s = {sides.north, sides.east, sides.south, sides.west}
	local items = {}
	for t = 1, #transposer do
		for i = 1, #s do
		size, error = transposer[t].getInventorySize(s[i])
			if error ~= "no inventory" then
				for j = 2,5 do
					item = transposer[t].getStackInSlot(s[i], j)
					if item ~= nil then
						while string.find(item.label, "§") do
							item.label = string.sub(item.label, 1, string.find(item.label, "§")-1) .. string.sub(item.label, string.find(item.label, "§")+3)
						end
						table.insert(items, item)
					else
						table.insert(items, {label = "Unknown"})
					end
				end
			else
				error = nil
			end
		end
	end
	return items --{item1, item2, item3, item4, item5, [...] } if there is no itemx then it is 'Unknown'
end

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

function pickNewObjective()
	local n = math.random(#objectives)
	outputRedstoneIOs[5].setOutput(redstoneOutputSide, 15)
	os.sleep(1)
	outputRedstoneIOs[5].setOutput(redstoneOutputSide, 0)
	return objectives[n]
end

function finishedObjective()
	w = 20
	h = 6
fileWrite("completionData.txt",completionData+1,true)
	gpu.setResolution(w,h)
	addRect(1,1,w,h,secondaryCol)
	centerText("Completed Objective!", 1, w, 2, textCol, secondaryCol)
	centerText("It will reset in:", 1, w, 3, textCol, secondaryCol)
	timeLeft = inbetweenGoalTime
	repeat
		os.sleep(1)
		timeLeft = timeLeft - 1
		centerText("  " .. timeLeft .. " seconds  ", 1, w, 4, textCol, secondaryCol)
	until timeLeft < 0
	os.execute("reboot")
end

function makeObjectives()
	local objectiveItems = getItems()
	local objectiveAmountsTemp = fileRead("data.txt")
	objectiveAmountsTemp = objectiveAmountsTemp[1]
	objectiveAmounts = {}
	while string.find(objectiveAmountsTemp, ";") do
		local a = string.find(objectiveAmountsTemp, ";")
		table.insert(objectiveAmounts, string.sub(objectiveAmountsTemp, 1, a-1))
		objectiveAmountsTemp = string.sub(objectiveAmountsTemp, a+1)
	end
	table.insert(objectiveAmounts, objectiveAmountsTemp)
	objectives = {}
	for i = 1, #objectiveItems do
		if #objectiveAmounts<i then
			table.insert(objectiveAmounts, 1)
		end
		table.insert(objectives, {objectiveItems[i].label, objectiveAmounts[i]})
	end
	local objectivesCopy = {}
	for i=1,#objectives do table.insert(objectivesCopy, objectives[i]) end
	local pagedObjectives = listToPages(objectivesCopy, 20)
	for j = 1, #pagedObjectives do
		for i = 1,#pagedObjectives[j] do
			print(pagedObjectives[j][i][1] .." = "..pagedObjectives[j][i][2])
		end
		--print("please click the screen to continue")
		--event.pull("touch")
		print("please wait ... loading ...")
		os.sleep(2)
		term.clear()
	end
end

function resetStuff()
	gpu.setForeground(0xffffff)
	gpu.setBackground(0x000000)
	term.clear()
end

function init()
	completionDataArray = fileRead("completionData.txt")
	completionData = tonumber(completionDataArray[1])
	timeLeft = goalCompletionTime
	resetStuff()
	makeObjectives()
	currentObjective = pickNewObjective()
	findItem()
	term.clear()
end

function main()
	update()
	screen()
	os.sleep(1)
end

function findItem()
	correctTransposer = nil
	local s = {sides.north, sides.east, sides.south, sides.west}
	for i = 1,#transposer do
		for j = 1, #s do
			size, error = transposer[i].getInventorySize(s[j])
			if error ~= "no inventory" then
				for k = 2,5 do
					local itemLabel = transposer[i].getStackInSlot(s[j], k).label
					while string.find(itemLabel, "§") do
						itemLabel = string.sub(itemLabel, 1, string.find(itemLabel, "§")-1) .. string.sub(itemLabel, string.find(itemLabel, "§")+3)
					end
					if itemLabel == currentObjective[1] then
						correctDrawerSide = s[j]
						correctTransposer = transposer[i]
						correctSlot = k
						return
					end
				end
			end
		end
	end
	throwError("finditem() "..correctSlot)
end

function flushDrawers()
	component.proxy(component.get(redstoneFlush)).setOutput(redstoneFlushSide, 15)
	repeat
		os.sleep(1)
	until correctTransposer.getStackInSlot(correctDrawerSide, correctSlot).size == 0
	component.proxy(component.get(redstoneFlush)).setOutput(redstoneFlushSide, 0)
end

function checkItem()
	local transposerAmount = correctTransposer.getStackInSlot(correctDrawerSide, correctSlot).size
	if transposerAmount >= currentObjective[2]*multiplier then
		storedAmount = transposerAmount
		filledPercentage = 1
		screen()
		flushDrawers()
		newGoal()
		return nil
	end
	return transposerAmount
end

function newGoal()
	completedObjective()
	displaySleepTime(height - 11,betweenGoalTime, textCol, secondaryCol, "Time left until next objective:", "")
	currentObjective = pickNewObjective()
	findItem()
	timeLeft = goalCompletionTime
end

function update()
	storedAmount = checkItem()
	if storedAmount ~= nil then
		filledPercentage = storedAmount/(currentObjective[2]*multiplier)
	else
		filledPercentage = 0
	end
	timeLeft = timeLeft - 1
	if timeLeft == -1 then
	    component.proxy(component.get(redstoneFlush)).setOutput(redstoneFlushSide, 15)
	    os.sleep(5)
	    component.proxy(component.get(redstoneFlush)).setOutput(redstoneFlushSide, 0)
		os.execute("reboot")
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

function displaySleepTime(y,toSleep, txtcol, bgcol, textToShowPre, textToShowPost)
	repeat
		centerText("   " .. textToShowPre .. " " .. math.floor(toSleep/60) .. " minutes and " .. toSleep%60 .. " seconds" .. textToShowPost .. "   ", 1, w, y, txtcol, bgcol)
		toSleep = toSleep - 1
		os.sleep(1)
	until toSleep == -1
end

function screen()
	--if currentTier == 1 then
		primaryCol = colorTable.uncommon.PrimaryCol
		secondaryCol = colorTable.uncommon.SecondaryCol
		textCol = colorTable.uncommon.textCol
		progressFilled = colorTable.uncommon.progressFilled
		progressEmpty = colorTable.uncommon.progressEmpty
	--end
	if currentTier == 2 then
		primaryCol = colorTable.rare.PrimaryCol
		secondaryCol = colorTable.rare.SecondaryCol
		textCol = colorTable.rare.textCol
		progressFilled = colorTable.rare.progressFilled
		progressEmpty = colorTable.rare.progressEmpty
	end
	if currentTier == 3 then
		primaryCol = colorTable.epic.PrimaryCol
		secondaryCol = colorTable.epic.SecondaryCol
		textCol = colorTable.epic.textCol
		progressFilled = colorTable.epic.progressFilled
		progressEmpty = colorTable.epic.progressEmpty
	end
	if currentTier == 4 then
		primaryCol = colorTable.legendary.PrimaryCol
		secondaryCol = colorTable.legendary.SecondaryCol
		textCol = colorTable.legendary.textCol
		progressFilled = colorTable.legendary.progressFilled
		progressEmpty = colorTable.legendary.progressEmpty
	end
	addRect(1,1,width,height,primaryCol)
	addRect(8,4,width-8,height-4,secondaryCol)
	gpu.setBackground(primaryCol)
	gpu.setForeground(textCol)
	addProgressBar(12,height - 10,width - 12,height - 6,2,1,primaryCol,progressFilled,progressEmpty,0x000000,"",filledPercentage,true,false)
	
	centerText("COMMUNITY CHALLENGE", 1, w, 5, textCol, secondaryCol)
	centerText("Work together to complete this challenge", 1, w, 7, textCol, secondaryCol)
	centerText("And everyone online will be rewarded!", 1, w, 9, textCol, secondaryCol)
 centerText("The current tier: " .. currentTier .. " - " .. subObjective, 1, w, 11, textCol, secondaryCol)
	
	centerText("Deliver " .. currentObjective[2]*multiplier .. " of " .. currentObjective[1] .. " to our community chest!", 1, w, height - 12, textCol, secondaryCol)
	centerText("Time remaining: " .. timeLeft, 1, w, height - 11, textCol, secondaryCol)
	if storedAmount ~= nil then
		centerText("Current objective is at: ".. storedAmount .." / ".. currentObjective[2]*multiplier, 1, w, height-5, textCol, secondaryCol)
	end
end

init()
repeat
	main()
until false