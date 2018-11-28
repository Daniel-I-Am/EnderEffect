local component = require("component")
local fs = require("filesystem")
local os = require("os")
local term = require("term")

local specialCharacter = "@"

methods = {}

methods.patterns = {
  ".*%]%]%-%-", --check for closing multiline comments
  "%-%-%[%[.-%]%]%-%-", --check for one line multiline comments
  "%-%-%[%[.*", --check for opening multiline comments
  "%-%-.*", --check for normal comments (like this one)
  "[%w%p]+%([%w%p% %\"%\']*%([%w%p% %\"%\']*%([%w%p% %\"%\']*%)[%w%p% %\"%\']*%)[%w%p% %\"%\']*%)", --check for triple function-ception
  "[%w%p]+%([%w%p% %\"%\']*%([%w%p% %\"%\']*%)[%w%p% %\"%\']*%)", --check for doule function-ception
  "[%w%p]+%([%w%p% %\"%\']*%)", --check for single functions --will have to try: [%w%d]-%b()
  "(\'(.-)\')", --check for strings with backed out ' (single quotes)
  "(\"(.-)\")", --check for strings with backed out " (duoble quotes)
  "0x%x%x%x%x%x%x", --check for hexadecimal numbers
  "%w+", --check for any left over words, like variables
  "." --check for any leftover symbols, spaces, etc (cleanup)
}

methods.patternColors = {
  0x696969, --comments
  0x696969, --comments
  0x696969, --comments
  0x696969, --comments
  0x00ffff, --function
  0x00ffff, --function
  0x00ffff, --function
  0xff00ff, --strings
  0xff00ff, --strings
  0xffff00, --hexadecimals
  0xffffff, --variables and such
  0xffffff --leftover (should be equal to 'defaultColor')
}

defaultColor = 0xffffff

local function encode(s)
  return (string.gsub(s, "\\(.)", function (x) return string.format("\\%03d", string.byte(x)) end))
end

local function decode(s)
  return (string.gsub(s, "\\(%d%d%d)", function (d) return "\\" .. string.char(d) end))
end

function methods.scrollLine(direction) --moves line in direction sign(direction) -> returns true, nil or false, errorReason
  if not component.isAvailable("gpu") then
    return false, "No component GPU found."
  end
  local gpu = component.gpu
  if direction == 0 then
    return false, "invalid direction specified"
  end
  if direction == nil then
    direction = 1
  end
  local width, height = gpu.getResolution()
  if direction > 0 then
    --move the screen up one and empty the bottom line
    gpu.copy(1, 1, w, h, 0, -1)
    gpu.fill(1, h - 1, w, 1, " ")
    return true, nil
  elseif direction < 0 then
    --move the screen down one and empty the top line
    gpu.copy(1, 1, w, h, 0, 1)
    gpu.fill(1, 1, w, 1, " ")
    return true, nil
  end
end

function methods.fixStringPattern(str)
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

function methods.pickTokenColor(token)
  for i, pattern in ipairs(methods.patterns) do
    if token:match(pattern) then
      return methods.patternColors[i]
    end
  end
  return defaultColor
end

function methods.highlight(tokens, lineToWrite) --highlight(tokens, lineToWrite) -> returns true, nil or false, errorReason
  if not component.isAvailable("gpu") then
    return false, "No component GPU found."
  end
  local gpu = component.gpu
  if type(tokens) ~= "table" then
    return false, "invalid argument 'tokens', expected table, got " .. type(tokens) .. "."
  end
  --start by getting some undo values
  prevForegroundColor = gpu.getForeground()
  term.setCursor(1, lineToWrite)
  for index, value in ipairs(tokens) do
    -- 'index' is the position in the array and 'value' is the token
    local tokenColor = methods.pickTokenColor(value) --returns a color to write in
    gpu.setForeground(tokenColor) --set that color, we can now forget about coloring
    
    --now the writing
    if value ~= nil then
      term.write(value)
    end
  end
  
  --reset undo values
  gpu.setForeground(prevForegroundColor)
end

function methods.sortTokens(tokens)
  indeces = {}
  values = {}
  for k,v in pairs(tokens) do
    table.insert(indeces, k)
    table.insert(values, v)
  end
  local maxIndex = 0
  for i = 1, #indeces do
    maxIndex = math.max(maxIndex, indeces[i])
  end
  sortedTokens = {}
  for i = 1, maxIndex do
    if tokens[i] ~= nil then
      table.insert(sortedTokens, tokens[i])
    end
  end
  return sortedTokens
end

function methods.findTokens(inputLine)
  local gpu = require("component").gpu
  local tokens = {}
  local printed = {}
  inputLine = encode(inputLine)
  for i = 1, inputLine:len() do
    printed[i] = false
  end
  local reducedLine = inputLine
  for _, pattern in ipairs(methods.patterns) do
    --cycle through all patterns
    local line = reducedLine
    for mtch in line:gmatch(pattern) do
      local emtch = methods.fixStringPattern(mtch) -- fix patterns
      if mtch ~= specialCharacter then --ignore if exactly specialCharacter (this won't get parsed either)
        --print("match: " .. mtch)
        --cycle through all matches for this pattern
        --reset some vars
        local foundStringStart = 0
        local foundStringEnd = 0
        --cycle through all instances of this match
        for tempMatch in line:gmatch(emtch) do
          --print("tmpmtach: " .. tempMatch)
          if tempMatch ~= nil then
            --find the position in the line
            local tempStringStart, tempStringEnd = line:find(emtch, foundStringEnd + 1)
            foundStringStart = tempStringStart
            foundStringEnd = tempStringEnd
            --print("start,end: " .. foundStringStart .. ", " .. foundStringEnd)
            if printed[foundStringStart] == false then
              --print("inserting: " .. foundStringStart .. " " .. mtch)
              mtch = decode(mtch)
              tokens[foundStringStart] = mtch
              mtch = encode(mtch)
            end
            --os.sleep(0.1)
            --adjust printed values
            for i = foundStringStart, foundStringEnd do
              printed[i] = true
            end
            --reduce the line
            tempStringStart, tempStringEnd = reducedLine:find(mtch)
            reducedLine = reducedLine:sub(1, foundStringStart - 1) .. string.sub(reducedLine:gsub(emtch, string.rep(specialCharacter, mtch:len())), foundStringStart, foundStringEnd) .. reducedLine:sub(foundStringEnd + 1)
            --print("reducedLine: " .. reducedLine)
          end
        end
      end
    end
  end
  sortedTokens = methods.sortTokens(tokens)
  return sortedTokens
end

function methods.splitLines(lineArray)
  if not component.isAvailable("gpu") then
    return false, "No component GPU found"
  end
  if type(lineArray) ~= "table" then
    return false, "invalid argument type, table expected, got " .. type(lineArray)
  end
  local width, _ = gpu.getResolution()
  local newLineArray = {}
  for index, value in ipairs(lineArray) do
    if type(value) ~= string then value = "" end
    if value:len() > width then
      --line is too long for current screen resolution
      local newLine = {}
      local toExecute = math.ceil(value:len() / width)
      for i = 1, toExecute do
        table.insert(newLine, value:sub(1, width))
        value = value:sub(width + 1)
      end
      table.insert(newLineArray, value)
    else
      --line is fine as is
      table.insert(newLineArray, value)
    end
  end
  return newLineArray
end

return methods