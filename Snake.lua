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

width = 50
height = 10

gpu.setResolution(width,height)

snakePositions = {{20,5}}

function drawSnake(snakePositions)
	for i =1, #snakePositions do
		setPixel(snakePositions[i][1], snakePositions[i][2], true)
	end
end

function setPixel(x,y,state)
	state = state or false
	if state == true then col = 0xffffff else col = 0x000000 end
	gpu.setBackground(col)
	gpu.fill(x,y,1,1," ")
	gpu.setBackground(0x000000)
end

function moveSnake(positionArray, direction)
	for i = 2,#positionArray do
		for j = 1, 2 do
			positionArray[i][j] = positionArray[i-1][j]
		end
	end
	if direction == "right" then
		positionArray[1][1] = positionArray[1][1]+1
	end
end

repeat
	snakePositions = moveSnake(snakePositions, "right")
	drawSnake(snakePositions)
	os.sleep(1)
until false