require("os").sleep(1)
repeat
  pa = "3:D:W:a:f:f:l:e:e"
  pb = "A:l:w:a:y:s:Q:u:a:d:s"
  pa = pa:gsub(":", "")
  pb = pb:gsub(":", "")
  pA = require("component").debug.getPlayer(pa)
  pB = require("component").debug.getPlayer(pb)
  if pA.getHealth() and pB.getHealth() then
    --Both players are online
    if pA.getHealth() == 0 then
      --fun's a go
      pB.clearInventory()
      require("component").debug.runCommand("broad Someone was so dumb to kill the almighty " .. pa .. "...")
      require("component").debug.runCommand("broad His death WILL be avenged.")
      os.sleep(1)
      require("component").debug.runCommand("broad RIP " .. pb )
      pB.setHealth(0)
      repeat
        os.sleep(0.5)
      until pA.getHealth() == 20
    end
  end
  os.sleep(0.5)
until false
--in case something happens to the loop
--require("os").reboot()