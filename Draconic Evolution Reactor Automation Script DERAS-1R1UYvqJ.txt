--#################################################################
--USEFUL FUNCTIONS
--reactor functions:

--getReactorInfo():
--failsafe
--fieldDrainRate
--maxFieldStrength
--fieldStrength
--energySaturation
--temperature
--maxEnergySaturation
--fuelConversion
--generationRate
--status
--maxFuelConversion
--fuelConversionRate

--stopReactor()

--flux gate functions:
--getFlow
--getSignalLowFlow
--setSignalLowFlow
--#################################################################

os = require("os")
io = require("io")
term = require("term")
component = require("component")

if not component.isAvailable("draconic_reactor") or not component.isAvailable("flux_gate") or not component.isAvailable("gpu") then
	print("Make sure a draconic reactor, flux gate and gpu are connected to the computer before running this script.")
	os.exit()
end

gpu = component.gpu
reactor = component.draconic_reactor.getReactorInfo()
gate = component.flux_gate
event = require("event")

args = {...}

isAutoStart = true
if args then
	if args[1] == "false" then
		isAutoStart = false
	end
end

--[[Colors Table]]--
colors = { black = 0x000000, white = 0xf8f8ff, blue = 0x0000ff, lightGray = 0xd9d9d9, red = 0xff0000,
purple = 0x9b30ff, carrot = 0xffa500, magenta = 0xcd00cd, lightBlue = 0x87cefa, yellow = 0xffff00,
lime = 0x32cd32, pink = 0xffc0cb, gray = 0x696969, brown = 0x8b4500, green = 0x006400, cyan = 0x008b8b,
olive = 0x6b8e23, gold = 0x8b6914, orangered = 0xdb4e02, diamond = 0x0fa7c7,crimson = 0xaf002a,fuchsia = 0xfd3f92,
folly = 0xff004f, frenchBlue = 0x0072bb, lilac = 0x86608e, flax = 0xeedc82, darkGray = 0x563c5c,
englishGreen = 0x1b4d3e, eggplant = 0x614051, deepPink  = 0xff1493, ruby = 0x843f5b, orange = 0xf5c71a,
lemon = 0xffd300, darkBlue = 0x002e63, bitterLime = 0xbfff00 }

width = 100 --df: 160
height = 50 --df: 50
barTextCol = colors.black
BGCol = colors.gray
maxTemp = 8000

function start()
  reactor = component.draconic_reactor.getReactorInfo()
  maxSat = reactor.maxEnergySaturation
  maxConv = reactor.maxFuelConversion
  maxShield = reactor.maxFieldStrength
  gate.setSignalLowFlow(0)
  if isAutoStart then
    component.draconic_reactor.chargeReactor()
  end
  component.draconic_reactor.setFailSafe(true)
  flow = reactor.generationRate
  gate.setSignalLowFlow(flow)
end

function shutdown()
  component.draconic_reactor.stopReactor()
  throwError("Reactor was shut down by program.")
end

function update()
  reactor = component.draconic_reactor.getReactorInfo()
  sat = reactor.energySaturation
  satp = math.floor(100*sat/maxSat+0.5)
  gen = reactor.generationRate
  conv = reactor.fuelConversion
  convp = math.floor(10000*conv/maxConv+0.5)/100
  flow = gate.getFlow()
  temp = reactor.temperature
  tempp = math.floor(100*temp/maxTemp+0.5)
  shield = reactor.fieldStrength
  shieldp = math.floor(100*shield/maxShield+0.5)
  status = reactor.status
end

function throwError(msg)
  gpu.setBackground(colors.black)
  gpu.setForeground(colors.white)
  gpu.setResolution(gpu.maxResolution())
  term.clear()
  print("An error was thrown during execution of this program:")
  print(tostring(msg))
  os.sleep(5)
  os.execute("/home/reactor.lua false")
end

function addRect(x1,y1,x2,y2,color)
  gpu.setBackground(color)
  gpu.fill(x1,y1,x2-x1+1,y2-y1+1," ")
end

function addBar(x1,y1,x2,y2,borderSize,barColFilled,barColEmpty,borderCol,textCol,filledp,text)
  addRect(x1,y1,x2,y2,borderCol)
  addRect(x1+borderSize,y1+borderSize,x2-borderSize,y2-borderSize,barColEmpty)
  barHeight = y2-y1-2*borderSize
  filledPixels = math.floor((barHeight*filledp)/100+0.5)
  addRect(x1+borderSize,y2-borderSize-filledPixels,x2-borderSize,y2-borderSize,barColFilled)
  gpu.setBackground(borderCol);gpu.setForeground(textCol);gpu.set(x1+borderSize,y1+borderSize-1,tostring(text))
end

function GUI()
  gpu.setBackground(BGCol)
  gpu.setResolution(width,height)
  term.clear()
  addTextCentered(2,"DRACONIC REACTOR AUTOMATION SCRIPT",colors.red,colors.gray)
  addTextCentered(3,"By Daniel_I_Am",colors.black,colors.gray)
end

function addText(x,y,text,FGCol,BGCol)
  gpu.setForeground(FGCol)
  gpu.setBackground(BGCol)
  gpu.set(x,y,text)
end
 
function comma_value(n) -- credit http://richard.warburton.it
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function center(y,text)
  width, height = gpu.getResolution()
  term.setCursor((width-string.len(text))/2+1, y)
  term.write(text)
end

function addTextCentered(y,str,FGCol,BGCol)
  gpu.setForeground(FGCol)
  gpu.setBackground(BGCol)
  center(y,tostring(str))
end

function screen()
--addBar(x1,x2,y1,y2,borderSize,barColFilled,barColEmpty,borderCol,textCol,filledp,text)
  addBar(2,5,15,height-1,2,colors.green,colors.black,colors.white,barTextCol,satp,"Saturation")
  addBar(width-33,5,width-19,height-1,2,colors.red,colors.black,colors.white,barTextCol,tempp,"Temperature")
  addBar(20,5,34,height-1,2,colors.blue,colors.black,colors.white,barTextCol,shieldp,"Containment")
  addBar(width-14,5,width-1,height-1,2,colors.orange,colors.black,colors.white,barTextCol,100-convp,"Conversion")
  addTextCentered(6,"  " .. tostring(comma_value(tostring(gen)).." RF/t Generated  "),colors.white,colors.gray)
  addTextCentered(7,"  " .. tostring(comma_value(tostring(flow)).." RF/t Flowrate  "),colors.white,colors.gray)
end

GUI()
start()

repeat
  update()
  screen()
  if status == "warming_up" then
    component.draconic_reactor.activateReactor()
  elseif status == "stopping" or status == "cooling" or status == "cold" then
    throwError("Reactor shut down due to outside sources.")
  else
    if sat and maxSat then
      if gen+5000>flow and satp>25 then
        flow = flow+10000
      elseif gen<flow and satp<10 then
        flow = math.floor((gen-5000)/10000)*10000
      end
      gate.setSignalLowFlow(flow)
    end
    if convp>95.00 and status == "running" then
      shutdown()
    end
    if temp > 7500 and status == "running" then
      shutdown()
    end
    if shield < 10 and status == "running" then
      shutdown()
    end
  end
  os.sleep(1)  
until false