local component = require("component")
local fs = require("filesystem")
local os = require("os")
local term = require("term")

if not component.isAvailable("gpu") then io.stderr:write("Do you really think you can use a program that uses color to display stuff without even bringing a GPU... what were you thinking?!"); io.stderr:write("You're such a moron that I won't even let you try to run this fancy program...");os.exit() end
local gpu = component.gpu

methods = {}

methods.patterns = {
  ".*%]%]", --check for closing multiline comments
  "%-%-%[%[.-%]%]", --check for one line multiline comments
  "%-%-%[%[.*", --check for opening multiline comments
  "%-%-.*", --check for normal comments (like this one)
  "[%w%p]+%b()", --check for functions
  "(\'(.-)\')", --check for strings with backed out ' (single quotes)
  "(\"(.-)\")", --check for strings with backed out " (duoble quotes)
  "0x%x%x%x%x%x%x", --check for hexadecimal numbers
  "%w+", --check for any left over words, like variables
  "." --check for any leftover symbols, spaces, etc (cleanup)
}

methods.pickColor = {
	"comment",
	"comment",
	"comment",
	"comment",
	"func",
	"str",
	"str",
	"hex",
	"words",
	"leftover"
}

methods.colors = {
	comment = 0x696969,
	func = 0x0000ff,
	str = 0x00ff00,
	hex = 0x00ffff,
	words = 0xffffff,
	leftover = 0xffffff
}

function methods.parsefile(file, startLine, stopLine)
	if startLine < 1 then startLine = 1 end
	local w, h = gpu.getResolution()
	term.clear()
	
	local function fileRead(fileLocation)
		local text = {}
		if fs.exists(tostring(fileLocation)) then
			local f = io.open(tostring(fileLocation), "r")
			repeat
				local line = f:read("*line")
				if line ~= nil then
					table.insert(text, line)
				end
			until line == nil
			f:close()
		end
		f = nil
		return text
	end
	
	local function parseLine(line, isStartComment)
		local toReturn = {}
		local nextLineIsComment = false
		if isStartComment then
			if line:find(methods.patterns[1]) ~= nil then
				local a, b = line:find(methods.patterns[1])
				--closing comment
				table.insert(toReturn, {1, methods.colors["comment"], line:sub(1, b)})
				line = line:sub(b + 1)
			else
				--no closing comment, so entirely comment
				nextLineIsComment = true
				return {{1, methods.colors["comment"], line}}, true
			end
		end
		--now the line does not start with a comment and we run the formats from top to bottom
		--no need to check the first, since that is dealt with up there
		for i = 2, #methods.patterns do
			shouldRep = true
			::startLoop::
			while shouldRep do
				local a, b = line:find(methods.patterns[i]) --find the current pattern
				if a == nil then
					shouldRep = false
					goto startLoop
				end
				--There is a pattern matching
				--the pattern is located in a to b
				if i == 3 then nextLineIsComment = true end
				table.insert(toReturn, {a, methods.colors[methods.pickColor[i]], line:sub(a,b)})
				line = line:sub(1, a-1) .. line:sub(b+1)
			end
		end
		return toReturn, nextLineIsComment
	end
	
	local function escapeSequences(str)
		local estr = str
		estr, _ = estr:gsub("%%", "%%%%")
		estr, _ = estr:gsub("%^", "%%^")
		estr, _ = estr:gsub("%$", "%%$")
		estr, _ = estr:gsub("%(", "%%(")
		estr, _ = estr:gsub("%)", "%%)")
		estr, _ = estr:gsub("%.", "%%.")
		estr, _ = estr:gsub("%[", "%%[")
		estr, _ = estr:gsub("%]", "%%]")
		estr, _ = estr:gsub("%*", "%%*")
		estr, _ = estr:gsub("%+", "%%+")
		estr, _ = estr:gsub("%-", "%%-")
		estr, _ = estr:gsub("%?", "%%?")
		--estr, _ = estr:gsub("%%%-%%%-", "--")
		return estr
	end
	
	local function printLine(height, originalLine, splitLine)
		--[[local l = 0
		for i = 1, #splitLine do
			l = l + string.len(splitLine[i][3])
		end
		--now we have the length of the complete sentence
		--Is that useful at all?
		--I kinda doubt it...
		--Can I remove it?
		--Might just need to leave it in, might be used somewhere...]]--
		gpu.set(1, height, originalLine)
		for i = 1, #splitLine do
			gpu.setForeground(splitLine[i][2])
			if originalLine:find(escapeSequences(splitLine[i][3])) ~= nil then
				gpu.set(originalLine:find(escapeSequences(splitLine[i][3])), height, splitLine[i][3])
			end
		end
	end
	
	local function getLines(linesInFile, start, stop)
		toReturn = {}
		for i = start, math.min(stop, #linesInFile) do
			table.insert(toReturn, linesInFile[i])
		end
		return toReturn
	end
	
	linesInFile = fileRead(file)
	linesToShow = getLines(linesInFile, startLine, math.min(stopLine, startLine + h - 2))
	prevLineEndedInAComment = false
	for i = 1, #linesToShow do
		originalLine = linesToShow[i]
		toShow, prevLineEndedInAComment = parseLine(originalLine, prevLineEndedInAComment)
		term.write("\n")
		printLine(i, originalLine, toShow)
	end
end

function methods.parseline(xOff, yOff, str)
	
	local function parseLine(line, isStartComment)
		local toReturn = {}
		local nextLineIsComment = false
		if isStartComment then
			if line:find(methods.patterns[1]) ~= nil then
				local a, b = line:find(methods.patterns[1])
				--closing comment
				table.insert(toReturn, {1, methods.colors["comment"], line:sub(1, b)})
				line = line:sub(b + 1)
			else
				--no closing comment, so entirely comment
				nextLineIsComment = true
				return {{1, methods.colors["comment"], line}}, true
			end
		end
		--now the line does not start with a comment and we run the formats from top to bottom
		--no need to check the first, since that is dealt with up there
		
		local function wordColorPicker(word)
			local colors = {black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000, purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00, lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b, olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92, folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c, englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a, lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00}
			
			local function pick(word)
				if word == "if" then return colors.red end
				if word == "then" then return colors.red end
				if word == "else" then return colors.red end
				if word == "end" then return colors.red end
				if word == "local" then return colors.red end
				if word == "nil" then return colors.red end
				if word == "repeat" then return colors.red end
				if word == "until" then return colors.red end
				if word == "while" then return colors.red end
				if word == "function" then return colors.red end
				if word == "return" then return colors.red end
				if word == "true" then return colors.yellow end
				if word == "false" then return colors.yellow end
				if word == "for" then return colors.red end
				if word == "in" then return colors.red end
				if word == "do" then return colors.red end
				if word == "or" then return colors.gold end
				if word == "and" then return colors.gold end
				if word == "not" then return colors.gold end
				return methods.colors["words"]
			end
			
			return pick(word)
		end
		
		for i = 2, #methods.patterns do
			shouldRep = true
			::startLoop::
			while shouldRep do
				local a, b = line:find(methods.patterns[i]) --find the current pattern
				if a == nil then
					shouldRep = false
					goto startLoop
				end
				--There is a pattern matching
				--the pattern is located in a to b
				if i == 3 then nextLineIsComment = true end
				local color = methods.colors[methods.pickColor[i]]
				if methods.pickColor[i] == "words" then
					color = wordColorPicker(line:sub(a,b))
				end
				table.insert(toReturn, {a, color, line:sub(a,b)})
				line = line:sub(1, a-1) .. line:sub(b+1)
			end
		end
		return toReturn, nextLineIsComment
	end
	
	local function escapeSequences(str)
		local estr = str
		estr, _ = estr:gsub("%%", "%%%%")
		estr, _ = estr:gsub("%^", "%%^")
		estr, _ = estr:gsub("%$", "%%$")
		estr, _ = estr:gsub("%(", "%%(")
		estr, _ = estr:gsub("%)", "%%)")
		estr, _ = estr:gsub("%.", "%%.")
		estr, _ = estr:gsub("%[", "%%[")
		estr, _ = estr:gsub("%]", "%%]")
		estr, _ = estr:gsub("%*", "%%*")
		estr, _ = estr:gsub("%+", "%%+")
		estr, _ = estr:gsub("%-", "%%-")
		estr, _ = estr:gsub("%?", "%%?")
		--estr, _ = estr:gsub("%%%-%%%-", "--")
		return estr
	end
	
	local function printLine(xOff, yOff, originalLine, splitLine)
		--[[local l = 0
		for i = 1, #splitLine do
			l = l + string.len(splitLine[i][3])
		end
		--now we have the length of the complete sentence
		--Is that useful at all?
		--I kinda doubt it...
		--Can I remove it?
		--Might just need to leave it in, might be used somewhere...]]
		--indeed, I ended up 'deleting' it
		gpu.set(xOff, yOff, originalLine)
		for i = 1, #splitLine do
			gpu.setForeground(splitLine[i][2])
			if originalLine:find(escapeSequences(splitLine[i][3])) ~= nil then
				gpu.set(xOff + originalLine:find(escapeSequences(splitLine[i][3])) - 1, yOff, splitLine[i][3])
			end
		end
	end
	
	prevLineEndedInAComment = false
	originalLine = str
	toShow, prevLineEndedInAComment = parseLine(originalLine, prevLineEndedInAComment)
	printLine(xOff, yOff, originalLine, toShow)
end

return methods