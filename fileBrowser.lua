fs = require("filesystem")
term = require("term")
event = require("event")
keyboard = require("keyboard")
os = require("os")

directory = "/"

function table.merge(t1, t2)
    for k,v in ipairs(t2) do
        table.insert(t1, v)
    end
    return t1
end

function listToPages(list,entriesPerPage)
    pageList = {}
    value = nil
    tempList = {}
    for i = 1,#list,entriesPerPage do
        tempList = {}
        for j = 1,entriesPerPage do
            value = table.remove(list, 1)
            table.insert(tempList, value)
        end
        table.insert(pageList, tempList)
    end
    return pageList
end

function listFiles(directory)
    files = {}
    dirs = {"../", "./"}
    for f in fs.list(directory) do
        if fs.isDirectory(directory .. f) then
            dirs[#dirs+1] = f
        else
            files[#files+1] = f
        end
    end
    return table.merge(dirs, files)
end

while not keyboard.isControlDown() do
    term.clear()
    files = listFiles(directory)
    filePage = listToPages(files, 5)
    for x = 1, #filePage do
        for y = 1, #filePage[x] do
            term.setCursor((x-1)*10+1, y)
            term.write(filePage[x][y])
        end
    end
    event.pull("touch")
end