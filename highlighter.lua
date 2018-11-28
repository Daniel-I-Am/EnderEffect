term = require("term")
component = require("component")
os = require("os")
io = require("io")
fs = require("filesystem")
startTime = os.time()
gpu = component.gpu

patterns = {
  ".*%]%]%-%-",
  "%-%-%[%[.-%]%]%-%-",
  "%-%-%[%[.*",
  "%-%-.*",
  "[%w%p]+%([%w%p% %\"%\']*%([%w%p% %\"%\']*%([%w%p% %\"%\']*%)[%w%p% %\"%\']*%)[%w%p% %\"%\']*%)",
  "[%w%p]+%([%w%p% %\"%\']*%([%w%p% %\"%\']*%)[%w%p% %\"%\']*%)",
  "[%w%p]+%([%w%p% %\"%\']*%)",
  "[%\"%\'][.*[%\\\"][%\\\']]*[%\"%\']",
  "(\'(.-\\\')\')",
  "\'[^(\\\')]-\'",
  "(\"(.-\\\")\")",
  "\"[^(\\\")]-\"",
  "0x%x%x%x%x%x%x",
  "%w+",
  "."
}

patternColors = {
  0x696969,
  0x696969,
  0x696969,
  0x696969,
  0xff00ff,
  0xff00ff,
  0xff00ff,
  0xff00ff,
  0xff00ff,
  0xffffff,
  0xffffff,
  0xffffff,
  0xffffff,
  0xffffff,
  0xffffff
}


lines = {
  "component = require(\"component\") --necessary",
  "gpu = component.gpu",
  "gpu.setResolution(gpu.maxResolution())",
  nil
}

red = "|if|then|end|else|"
green = "|=|"
blue = "|local |"

isComment = false
willBeComment = false
multilineCommentOpenArrayPosition = 3
multilineCommentCloseArrayPosition = 1
width, height = gpu.getResolution()

function throwError(errorMessage)
  if component.isAvailable("gpu") then
    gpu.setResolution(gpu.maxResolution())
    gpu.setForeground(0xff0000)
    gpu.setBackground(0x000000)
  end
  term.clear()
  print("The program ran into a serious error during execution.")
  print(errorMessage)
  if component.isAvailable("gpu") then
    gpu.setForeground(0xffffff)
  end
  os.exit()
end

function fileRead(fileLocation)
    local text = {}
    if fs.exists(tostring(fileLocation)) then
        f = io.open(tostring(fileLocation), "r")
        repeat
            line = f:read("*line")
            if line ~= nil then
        fixStringPattern(line)
                table.insert(text, line)
            end
        until line == nil
    else
        throwError("File ".. fileLocation .." not found!")
    end
    f:close()
    f = nil
    return text
end

function colorToken(estr, patternNumber)
  local toOutput = patternColors[patternNumber]
  isRed = string.match(red, "|" .. estr .. "|")
  isGreen = string.match(green, "|" .. estr .. "|")
  isBlue = string.match(blue, "|" .. estr .. "|")
  if isRed then toOutput = 0xff0000
  elseif isGreen then toOutput = 0x00ff00
  elseif isBlue then toOutput = 0x0000ff
  end
  return toOutput
end

function fixStringPattern(str)
  local estr = str
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
  estr, _ = estr:gsub("%%%-%%%-", "--")
  return estr
end

arg = ...
if arg ~= nil then
  lines = fileRead("/home/" .. arg)
end

j = 1
repeat
    line = lines[j]
  reducedLine = line
  printed = {}
  j = j + 1
  if line ~= nil then
    for i = 1, line:len() do
      printed[i] = false
    end
    isComment = willBeComment
    for i = 1, #patterns do
      for foundStr in reducedLine:gmatch(patterns[i]) do
        if foundStr ~= nil then
          if i == multilineCommentOpenArrayPosition then
            willBeComment = true
          elseif i == multilineCommentCloseArrayPosition then
            willBeComment = false
            isComment = false
          end
          str = foundStr
          --fixing some patterns ._.
          estr = fixStringPattern(str)
          _, h = gpu.getResolution()
          stringEnd = 1
          for toWrite in line:gmatch(estr) do
            stringStart, stringEnd = line:find(estr, stringEnd)
            canPrint = true
            for k = stringStart, stringEnd do
              if printed[k] == true then
                canPrint = false
              end
            end
            if canPrint then
              for k = stringStart, stringEnd do
                printed[k] = true
              end
              if isComment == true then
                gpu.setForeground(patternColors[1])
                _,y = term.getCursor()
                term.setCursor(1,y)
                term.write(line)
                reducedLine = ""
              else
                writeColor = colorToken(estr, i)
                _,y = term.getCursor()
                term.setCursor(stringStart ,y + math.floor(stringStart / width))
                gpu.setForeground(writeColor)
                term.write(str)
                reducedLine, _ = reducedLine:gsub(estr, "")
              end
            end
          end
        end
      end
    end
  end
	if line ~= nil then
		term.setCursor(width, y + math.floor(line:len() / width))
	end
    term.write("\n")
until line == nil
gpu.setForeground(0xffffff)

endTime = os.time()
print("\n")
print(startTime)
print(endTime)
print(endTime - startTime)