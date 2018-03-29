io = require("io")
os = require("os")
internet = require("internet")
fs = require("filesystem")

path = "/home/pricelist.txt"
list = {}

os.execute("rm /home/pricelist.txt")
os.execute("edit /home/pricelist.txt")

function removeFiles()
  fs.remove("pricelistCommon.txt")
  fs.remove("pricelistUncommon.txt")
  fs.remove("pricelistRare.txt")
  fs.remove("pricelistEpic.txt")
  fs.remove("pricelistLegendary.txt")
end

function createFiles()
  common = io.open("/home/pricelistCommon.txt","w")
  uncommon = io.open("/home/pricelistUncommon.txt","w")
  rare = io.open("/home/pricelistRare.txt","w")
  epic = io.open("/home/pricelistEpic.txt","w")
  legendary = io.open("/home/pricelistLegendary.txt","w")
end

function getTier(str)
  if str == "Common" then return common
  elseif str == "Uncommon" then return uncommon
  elseif str == "Rare" then return rare
  elseif str == "Epic" then return epic
  elseif str == "Legendary" then return legendary
  else print("you messed up :p"); return "incorrect"
  end
end

function closeFiles()
  common:close()
  uncommon:close()
  rare:close()
  epic:close()
  legendary:close()
end

function fileWrite(file,str)
  file:write(str.."\n")
  file = nil
end

function downloadList(path)
  pricelistFile = io.open(path,"r")
  pricelist = pricelistFile:read("*a")
end

downloadList(path)
repeat
  a = nil
  a = string.find(pricelist,";")
  if a then
    table.insert(list,string.sub(pricelist,1,a-1))
    pricelist = string.sub(pricelist,a+1,-1)
  end
until a == nil
table.insert(list,pricelist)
pricelist = nil

--expected data: <itemname>,<itemprice>,<itemtier>;next one
removeFiles()
createFiles()
for i=1,#list do
  a = string.find(list[i],",")
  b = string.find(string.sub(list[i],a+1,-1),",") + a
    --print(string.sub(list[i],1,a-1))
    --print(string.sub(list[i],a+1,b-1))
    --print(string.sub(list[i],b+1,-1))
  tier = getTier(string.sub(list[i],b+1,-1))
  if tier == "incorrect" then
    print("There was a mistake with item: "..string.sub(list[i],1,a-1))
    print("The price was labeled as: "..string.sub(list[i],a+1,b-1))
    os.sleep(2)
  else
    fileWrite(tier,string.sub(list[i],1,a-1)..";"..string.sub(list[i],a+1,b-1))
  end
  print("")
  a = nil; b = nil
end
closeFiles()

os.execute("edit pricelistCommon.txt")
os.execute("edit pricelistUncommon.txt")
os.execute("edit pricelistRare.txt")
os.execute("edit pricelistEpic.txt")
os.execute("edit pricelistLegendary.txt")
os.execute("pricelist.lua")