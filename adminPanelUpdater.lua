os = require("os")
toDownload = {"adminPanel.lua", "Qi69fH6T", "snake.lua", "cfHDTgt2", "update.lua", "abXQKMqa"}
for i = 1, #toDownload, 2 do
	os.execute("pastebin get -f " .. toDownload[i+1] .. " " .. toDownload[i])
end