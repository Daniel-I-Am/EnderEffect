local gpu = require("component").gpu

method = {}

local Buttons = {}

local function Split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function method.clear()
  Buttons = {}
end

function method.makeButton(xOff,yOff,w,h,Bcolor,Tcolor,sXOff,sYOff,str)
  Buttons[tonumber(#Buttons) +1] = xOff..","..yOff..","..w..","..h..","..Bcolor..","..Tcolor..","..sXOff..","..sYOff..","..str
end

local function drawButton(xOff,yOff,w,h,Bcolor,Tcolor,sXOff,sYOff,str)
  local prevFColor = gpu.getForeground()
  local prevBColor = gpu.getBackground()

  if Bcolor ~= -1 then
    gpu.setForeground(Bcolor)
    gpu.fill(xOff,yOff,w,h,"█")
  end

  if Tcolor ~= -1 then
    gpu.setForeground(Tcolor)
    if sXOff == -1 or sYOff == -1 then
      sXOff = math.floor((w/2 - #str/2)+0.5)
      sYOff = math.floor(h/2)
    end

    for i = 0,#str - 1 do 
      _, color = gpu.get(xOff+i+sXOff,yOff+sYOff)
      gpu.setBackground(color)
      gpu.set(xOff + sXOff + i,yOff+sYOff,string.sub(str,i+1,i+1))
    end

  end

  gpu.setBackground(prevBColor)
  gpu.setForeground(prevFColor)
end

function method.drawAll()
  for i,v in pairs(Buttons) do
    str = Split(v,",")
    drawButton(tonumber(str[1]),tonumber(str[2]),tonumber(str[3]),tonumber(str[4]),tonumber(str[5]),tonumber(str[6]),tonumber(str[7]),tonumber(str[8]),str[9])
  end
end

function method.draw(IDA)
  for i,v in ipairs(IDA) do
    if Buttons[v] ~= nil then
      str = Split(Buttons[v],",")
      drawButton(tonumber(str[1]),tonumber(str[2]),tonumber(str[3]),tonumber(str[4]),tonumber(str[5]),tonumber(str[6]),tonumber(str[7]),tonumber(str[8]),str[9])
    end
  end
end

local function updateBut(xOff,yOff,w,h,clickX,clickY)
  if (clickX >= xOff and clickX < xOff+w) and (clickY >= yOff and clickY < yOff + h) then
    return true
  else
    return false
  end
end

function method.updateAll(_,_,x,y,_,_)
  local buttonsClicked = {}
  for i,v in pairs(Buttons) do
    str = Split(v, ",")
    if updateBut(tonumber(str[1]),tonumber(str[2]),tonumber(str[3]),tonumber(str[4]),x,y) == true then
      buttonsClicked[#buttonsClicked + 1] = i
    end
  end
  return buttonsClicked
end

function method.update(IDA,_,_,x,y,_,_)
  local buttonsClicked = {}
  for i,v in pairs(IDA) do
    if Buttons[v] ~= nil then
      str = Split(Buttons[v],",")
      if updateBut(tonumber(str[1]),tonumber(str[2]),tonumber(str[3]),tonumber(str[4]),x,y) == true then
        buttonsClicked[#buttonsClicked + 1] = i
      end
    end
  end
  return buttonsClicked
end

return method