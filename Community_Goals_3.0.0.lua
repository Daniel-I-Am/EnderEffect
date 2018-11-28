local isFirstRun = true
function resetAllTheThings()
--[[
	just some goals
	stuff commented with '--DISABLE' is disabled during tested, just by commenting it out
]]--

computer = require("computer")
os = require("os")
io = require("io")
term = require("term")
dan = require("danAPI")
BA = require("ButtonAPI")
component = require("component")
event = require("event")
sides = require("sides")
computer = require("computer")

--check for components
if not component.isAvailable("gpu") or not component.isAvailable("screen") or not component.isAvailable("debug") or not component.isAvailable("transposer") then
	io.write("This program requires a gpu, screen, transposer and debug card to function.")
	return
end
gpu = component.gpu
debugCard = component.debug
screen = component.screen

local completionData = tonumber(dan.fileRead("/home/data.txt")[1])

screen.setTouchModeInverted(true)

transposers = {
	"242", "b82", "842", "04c", "8f7", "168"
}

flushRedstoneIO = component.proxy(component.get("315"))
flushSide = sides.east

--[[
requestedAmounts = {
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16, 
	16, 16, 16, 16
}
]]--

requestedAmounts = {
	32, 24, 1024, 48, --Sleigh, Wireless Booster, Tardis, Octadic
	64, 256, 16, 256, --64k's, 16k's, Supreme Pizza, Blank Pattern
	1024, 32, 48, 24, --Transistor, GPU T3, Transposer, Cooked Tofenison
	32, 64, 32, 64, --Gem of Self Sacrifice, Mana Spreader, Floating Thermalily, Wyvern Core
	256, 8192, 2048, 64, --Iridium Reinforced Stone, XP Shard, Crop Sticks, Flux Plug
	512, 16, 256, 512, --Lightning Rod, Magnetron, Mixed Metal Ingot, ME Dense Cable - Pink
	32, 12, 72, 48, --Bacon Cheeseburger, Epic Bacon, Empowered Void Crystal, Mana Pearl
	1024, 32, 24, 16, --Humus, Sunnarium, Irradiant Reinforced Plate, MT Core
	192, 192, 32, 768, --Awakened Draconium Ingot, Overclocker Upgrade, Focus Sash, Nether Star
	64, 32, 24, 48, --Lens of Color, Generator Block, Keyboard, Phantomface
	24, 64, 512, 32, --Concentrated Cloud Seed Bucket, Fluxed Electrum Blend, Psigem, Cup of Coffee
	8, 64, 64, 32, --T1 Key, Dark Steel Ball, Reinforced Servo, Tiny Potato Mask
	512, 128, 256, 48, --ME Storage Housing, Fel Pumpkin, Solar Panel II, Superconductors
	24, 64, 32, 32, --Mob Prism Frame, Fluxed Phyto-gro, Gold Plated Skull, UnderIron Plate
	72, 128, 64, 64, --Mob Swab, Whistle Tuner, Diamond Sword, Storage Downgrade
	512, 128, 32, 24, --Paper Cone, Elementium Ingot, Opinium Core (decent), Iridium Neutron Reflector
	24, 48, 64, 512, --Zesty Zucchini, Habitat Locator, Transformer Upgrade, Stone Pickaxe
	64, 64, 256, 64  --Phanton Ink, Silky Jewel, Spectral Arrow, Drawer Controller
}

colorTable = {
    {
        PrimaryCol = 0x36c95e,
        SecondaryCol = 0x1b642f,
    textCol = 0xffffff,
    progressFilled = 0x00ff00,
    progressEmpty = 0x000000
    },
    {
        SecondaryCol = 0x21416c,
        PrimaryCol = 0x4283d8,
    textCol = 0xffffff,
    progressFilled = 0x0000ff,
    progressEmpty = 0x000000
    },
    {
        SecondaryCol = 0x4e2964,
        PrimaryCol = 0x9c52c8,
    textCol = 0xffffff,
    progressFilled = 0xcc66ff,
    progressEmpty = 0x000000
    },
    {
        SecondaryCol = 0xdd871c,
        PrimaryCol = 0x6e430e,
    textCol = 0xffffff,
    progressFilled = 0xff9933,
    progressEmpty = 0x000000
    }
}

currentTier = 1
subObjective = 1


amountOfTierOneObjectives = 4
amountOfTierTwoObjectives = 8
amountOfTierThreeObjectives = 4
amountOfTierFourObjectives = 1

multipliers = {1 * 1.1 ^ completionData, 3 * 1.2 ^ completionData , 10 * 1.3 ^ completionData , 35 * 1.4 ^ completionData}

announcePrefix = "&r&f&l[&c&lCommunity Goal&r&f&l]&r"
announceSuffix = "&r&fType &7/warp community &fto head over and take a look!&r"

announceNewGoal = "&rNew &cCommunity Goal &fset!&r"
announceTimeUp = "&r&cCommunity Goal &ffailed :C&r"
announceWinKey1 = "&r&bCongratulations! &fYou won a tier 1 key!"
announceWinKey2 = "&r&bCongratulations! &fYou won a tier 2 key!"
announceWinKey3 = "&r&bCongratulations! &fYou won a tier 3 key!"
announceWinKey4 = "&r&bCongratulations! &fYou won a tier 4 key!"

timeForObjectives = 3600
timeBetweenObjectives = 60
timeBetweenFullGoals = 7200

minSkipPCT = 0.25

width = 120
height = 30
gpu.setResolution(width, height)

hasSkippedTier = false

globalTextBG = 0x000000
end
resetAllTheThings()
args = {...}

function checkArgs()
	if args ~= nil then
		for _, arg in pairs(args) do
			if arg == "--readoutItems" then
				gpu.setResolution(gpu.maxResolution())
				itemList = scanDrawers()
				term.clear()
				print("Item readout:")
				for i = 1, #requestedAmounts/2 do
					gpu.set(1, i, itemList[i] .. ": " .. requestedAmounts[i])
				end
				for i = #requestedAmounts/2, #requestedAmounts do
					gpu.set(width/2, i - #requestedAmounts/2, itemList[i] .. ": " .. requestedAmounts[i])
				end
				term.setCursor(1, #requestedAmounts/2 + 1)
				os.exit()
			else
				currentTier = tonumber(arg:sub(1, arg:find("-") - 1))
				subObjective = tonumber(arg:sub(arg:find("-") + 1))
			end
		end
	end
	args = nil
end

function init()
	flushRedstoneIO.setOutput(flushSide, 15)
	os.sleep(10)
	flushRedstoneIO.setOutput(flushSide, 0)
	
	for i = 1, #transposers do --get the actual transposer array
		transposers[i] = component.proxy(component.get(transposers[i]))
	end
	checkArgs()
	BA.clear()
	BA.makeButton(1, height-2, width, 3, 0x696969, 0xffffff, -1, -1, "vote skip")
	itemList = scanDrawers()
end

function reset()
	gpu.set(1,height - 3, "Skipped                                       ")
	gpu.fill(1, height, width, 1, " ")
	if not isFirstRun then
		displaySleepTime(height - 2, timeBetweenObjectives, 0xffffff, colorTable[currentTier].SecondaryCol, "Time left till next objective:", "")
		isFirstRun = false
	end
	haveSkipped = {}
	skipVotes = 0
	timeLeft = timeForObjectives
	makeNewObjective()
	BA.drawAll()
end

function getTime()
  local unformattedTime = os.date()
  local dayWeek = unformattedTime:sub(1,3)
  local mon = unformattedTime:sub(5,7)
  local day = unformattedTime:sub(9,10)
  local hour = unformattedTime:sub(12,13)
  local minute = unformattedTime:sub(15,16)
  local second = unformattedTime:sub(18,19)
  local year = unformattedTime:sub(21)
  return {dayWeek = dayWeek, month = mon, dayMon = day, hour = hour, minute = minute, second = second, year = year}
end

function displaySleepTime(y,toSleep, txtcol, bgcol, textToShowPre, textToShowPost, customWidth)
  if customWidth ~= nil then local localWidth = customWidth else local localWidth = width end
  repeat
    dan.centerText("     " .. textToShowPre .. " " .. math.floor(toSleep/60) .. " minutes and " .. toSleep%60 .. " seconds" .. textToShowPost .. "     ", 1, localWidth, y, txtcol, bgcol)
    toSleep = toSleep - 1
    os.sleep(1)
  until toSleep == -1
end

function completelyFinishedGoals()
  gpu.setForeground(0xff0000)
  gpu.setBackground(0x000000)
  gpu.setResolution(50,3)
  local localWidth = 50
  term.clear()
  dan.centerText("Congratulations, the community beat the goals!", 1, localWidth, 1, 0xff0000, 0x000000)
  dan.centerText("Please be patient", 1, localWidth, 3, 0xff0000, 0x000000)
  displaySleepTime(2, timeBetweenFullGoals, 0xff0000, 0x000000, "Resetting in: ", "", localWidth)
  gpu.setResolution(width, height)
end

function upTheObjective()
  if currentTier == 1 then
    subObjective = subObjective + 1
    if subObjective > amountOfTierOneObjectives then
	  hasSkippedTier = false
      currentTier = 2
      subObjective = 1
    end
  elseif currentTier == 2 then
    subObjective = subObjective + 1
    if subObjective > amountOfTierTwoObjectives then
	  hasSkippedTier = false
      currentTier = 3
      subObjective = 1
    end
  elseif currentTier == 3 then
    subObjective = subObjective + 1
    if subObjective > amountOfTierThreeObjectives then
	  hasSkippedTier = true
      currentTier = 4
      subObjective = 1
    end
  elseif currentTier == 4 then
    subObjective = subObjective + 1
    if subObjective > amountOfTierFourObjectives then
      completelyFinishedGoals()
	  currentTier = 1
      subObjective = 1
    end
  end
end

function flushDrawer(transposerID, drawerSide, drawerSlot)
	if transposerID.getStackInSlot(drawerSide, drawerSlot) == nil then
		return
	end
	flushRedstoneIO.setOutput(flushSide, 15)
	while transposerID.getStackInSlot(drawerSide, drawerSlot).size > 0 do
		os.sleep(1)
	end
	flushRedstoneIO.setOutput(flushSide, 0)
end

function announceAndGiveKey()
	local announcements = {announceWinKey1, announceWinKey2, announceWinKey3, announceWinKey4}
	giveKeyToPeople()
	announce(announcements[currentTier])
end

function makeNewObjective()
	randomNumber = math.random(80, 125)/100
	timeLeft = timeForObjectives
	prevItem = currentItem
	currentItem, index = pickItem(itemList, prevItem)
	drawerInfo = findCorrectDrawerSlot(currentItem)
	announce(announceNewGoal .. " (" .. currentItem .. ")")
end

function scanDrawers()
	local foundItems = {}
	for _, currentTransposer in pairs(transposers) do
		--cycle through given transposers
		for currentSide = 2, 5 do
			--cycle through sides
			if currentTransposer.getInventorySize(currentSide) ~= nil then
				for currentSlot = 2, 5 do
					--cycle through slots
					local foundItem = currentTransposer.getStackInSlot(currentSide, currentSlot)
					if foundItem == nil then foundItem = {label = "nil"} end
					local itemName = foundItem.label
					itemName = itemName:gsub("§[abcdef%d]", "")
					table.insert(foundItems, itemName)
				end
			end
		end
	end
	return foundItems
end

function pickItem(itemLst, prevItem)
	prevItem = prevItem or "nil"
	local newItem
	local index
	repeat
		index = math.random(1, #itemLst)
		newItem = itemLst[index]
	until newItem ~= prevItem
	return newItem, index
end

function findCorrectDrawerSlot(itemName)
	for _, currentTransposer in pairs(transposers) do
		--cycle through given transposers
		for currentSide = 2, 5 do
			--cycle through sides
			if currentTransposer.getInventorySize(currentSide) ~= nil then
				for currentSlot = 2, 5 do
					--cycle through slots
					local itemInSlot = currentTransposer.getStackInSlot(currentSide, currentSlot)
					if itemInSlot ~= nil then
						if itemInSlot.label:gsub("§[abcdef%d]", "") == itemName then
							return {transposer = currentTransposer, side = currentSide, slot = currentSlot}
						end
					end
				end
			end
		end
	end
	dan.throwError("did not find item " .. itemName .. " in drawers")
end

function checkCorrectDrawer(drawerInfo)
	local foundItem = drawerInfo.transposer.getStackInSlot(drawerInfo.side, drawerInfo.slot)
	if foundItem == nil then return 2147483647 end
	return foundItem.size
end

function giveKeyToPeople()
	local nbtTag = ""
	if currentTier == 1 then nbtTag = "{display:{Name:\"§bTier 1 §aSlotmachine §bKey\",Lore:[\"§eLevel : [TIER 1]\",\"§bWith this key you can try the §aSlotmachine§0!\"]}}"
		elseif currentTier == 2 then nbtTag = "{display:{Name:\"§9Tier 2 §aSlotmachine §bKey\",Lore:[\"§eLevel : §9[TIER 2]\",\"§bWith this key you can try the §aSlotmachine§0!\"]}}"
		elseif currentTier == 3 then nbtTag = "{display:{Name:\"§5Tier 3 §aSlotmachine §bKey\",Lore:[\"§eLevel : §5[TIER 3]\",\"§bWith this key you can try the §aSlotmachine§0!\"]}}"
		elseif currentTier == 4 then nbtTag = "{display:{Name:\"§6Tier 4 §aSlotmachine §bKey\",Lore:[\"§eLevel : §6[TIER 4]\",\"§bWith this key you can try the §aSlotmachine§0!\"]}}"
	end
	local currentlyOnlinePlayers = debugCard.getPlayers()
	for _, player in pairs(currentlyOnlinePlayers) do
		if player ~= "SpikeyThorn" and player ~= "Mushdohr" and player ~= "MrGulliien" then
			if type(player) == "string" then
				debugCard.getPlayer(player).insertItem("minecraft:tripwire_hook", 1, 0, nbtTag) --DISABLE
			end
		end
	end
end

function announce(toAnnounce)
	debugCard.runCommand("broad " .. announcePrefix .. " " .. toAnnounce .. " " .. announceSuffix) --DISABLE
end

function addText()
	dan.centerText("COMMUNITY CHALLENGE", 1, width, 2, 0xffffff, colorTable[currentTier].SecondaryCol)
	dan.centerText("Work together to complete this challenge", 1, width, 4, 0xffffff, colorTable[currentTier].SecondaryCol)
	dan.centerText("And everyone online will be rewarded!", 1, width, 6, 0xffffff, colorTable[currentTier].SecondaryCol)
	dan.centerText("Just drop down the items needed to submit them", 1, width, 8, 0xffffff, colorTable[currentTier].SecondaryCol)
	dan.centerText("(careful for clearlag)", 1, width, 9, 0xffffff, colorTable[currentTier].SecondaryCol)
	dan.centerText("The skip button can be used once per tier!", 1, width, 10, 0xffffff, colorTable[currentTier].SecondaryCol)
	dan.centerText("The current tier: " .. currentTier .. " - " .. subObjective, 1, width, 12, 0xffffff, colorTable[currentTier].SecondaryCol)
end

--The main code block:
init()
reset()
repeat
	storedAmount = checkCorrectDrawer(drawerInfo) --checks stored amount
	requestedAmount = math.ceil(requestedAmounts[index] * multipliers[currentTier] * randomNumber) --makes sure to have latest request
	storedPCT = storedAmount / requestedAmount --percentage
	--do all the screen stuff
	local tempVar = gpu.getBackground()
	gpu.setBackground(colorTable[currentTier].SecondaryCol)
	term.clear() --clear screen
	gpu.setBackground(tempVar)
	tempVar = nil
	addText()
	dan.addProgressBar(5, 20, -5, 24, 2, 1, 0x696969, colorTable[currentTier].PrimaryCol, colorTable[currentTier].SecondaryCol, 0xff00ff, "", storedPCT, true, false) --add progress bar
	dan.centerText("Currently requesting " .. tostring(math.max(0, requestedAmount - storedAmount)) .. " more of " .. currentItem .. " out of " .. requestedAmount .. " (" .. math.floor(math.min(100,storedPCT * 100)*10)/10 .. "%)", 1, width, 25, colorTable[currentTier].textCol, colorTable[currentTier].SecondaryCol) --text about completion
	if hasSkippedTier == false then
		BA.drawAll() --draw Button
	else
		gpu.fill(1, height - 2, width, 2, " ") -- remove button
		gpu.set(1, height - 3, "Already skipped on this tier, next vote skip available at the next tier") --replace with text
	end
	--end of drawing
	if storedPCT >= 1 then
		haveSkipped = {}
		skipVotes = 0
		announceAndGiveKey()
		flushDrawer(drawerInfo.transposer, drawerInfo.side, drawerInfo.slot)
		displaySleepTime(height - 4, timeBetweenObjectives, 0xffffff, colorTable[currentTier].SecondaryCol, "Time left till next objective:", "") --timer
		upTheObjective()
		makeNewObjective()
	end
	timeLeft = timeLeft - 1
	if timeLeft < 0 then
		announce(announceTimeUp)
		flushDrawer(drawerInfo.transposer, drawerInfo.side, drawerInfo.slot)
		resetAllTheThings()
		init()
		reset()
	else
		dan.centerText("     Time left: " .. math.floor(timeLeft/60) .. " minutes and " .. timeLeft % 60 .. " seconds     ", 1, width, 26, 0xffffff, colorTable[currentTier].SecondaryCol)
		if skipVotes and amountPlayersOnline then
			gpu.setForeground(0xffffff)
			gpu.setBackground(colorTable[currentTier].SecondaryCol)
			if not hasSkippedTier then
				if skipVotes == 1 then gpu.set(1, height - 3, tostring(skipVotes) .. " player has voted to skip out of " .. tostring(math.ceil(minSkipPCT * amountPlayersOnline)) .. " needed") --skip counter
				else gpu.set(1, height - 3, tostring(skipVotes) .. " players have voted to skip out of " .. tostring(math.ceil(minSkipPCT * amountPlayersOnline)) .. " needed") end --skip counter
			end
		end
		local timeout = computer.uptime() + 1
		e,_,x,y,_,p = event.pull(1, "touch")
		if e ~= nil then
			clickedButtonList = BA.updateAll(e,_,x,y,_,_)
		end
		while computer.uptime() < timeout do
			os.sleep(0.05)
		end
		if clickedButtonList then
			clickedButton = clickedButtonList[1]
			clickedButtonList = nil
		end
		if clickedButton == 1 then
			haveSkipped[p] = true
			
			currentlyOnlinePlayers = debugCard.getPlayers()
			amountPlayersOnline = #currentlyOnlinePlayers
			--count skip players
			skipVotes = 0
			for k,v in pairs(haveSkipped) do
				if v == true then
					skipVotes = skipVotes + 1
				end
			end
			if skipVotes >= math.ceil(amountPlayersOnline * minSkipPCT) and hasSkippedTier == false then
				hasSkippedTier = true
				flushDrawer(drawerInfo.transposer, drawerInfo.side, drawerInfo.slot)
				reset()
			end
			clickedButton = nil
		end
	end
until false