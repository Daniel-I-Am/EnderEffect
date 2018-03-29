BA = require("ButtonAPI")
comp = require("component")
computer = require("computer")
dan = require("danAPI")
event = require("event")
fs = require("filesystem")
keyboard = require("keyboard")

if not comp.isAvailable("tunnel") then return end

tunnel = comp.tunnel
repeat
	tunnel.send(tostring(io.stdin:read()))
until false