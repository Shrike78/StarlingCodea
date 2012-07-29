-- IO

--[[

IO offers a way to easily access files from 3 different mountinpoint:
- Dropbox (and subfolders)
- Documents (and subfolders)
- A defined Spritepack

The default mount point is Dropbox but at the beginning of a project 
that can be set to a desired working dir calling global function

IO.setWorkingDir(mountPoint,folder)
--]]
---[[
IO = {}

IO.DOCUMENTS = "Documents"
IO.DROPBOX = "Dropbox"
IO.SPRITEPACK = "SpritePacks"

--for debug purpose, it's possible to set as true and simulate
--sandboxed environment even in a unsandoboxed one
IO.__simulateSandbox = false

local __mountPoint = IO.DROPBOX
local __folder = nil

--[[
- mountPoint: IO.DOCUMENTS, IO.DROPBOX or IO.SPRITEPACK
- folder: if mountPoint is DOCUMENTS or DROPBOX, it can be a subfolder
name or nil (for base mountPoint dir). If mountPoint is SPRITEPACK 
instead, folder is thename of the desired spritepack and cannot be nil.

Pay attention, folders and fileNames are case sensitive.
--]]
function IO.setWorkingDir(mountPoint,folder)
    assert(mountPoint == IO.DOCUMENTS or
            mountPoint == IO.DROPBOX or
            mountPoint == IO.SPRITEPACK,
            mountPoint .. " is not a valid mountPoint")
    __mountPoint = mountPoint
    
    assert(mountPoint ~= IO.SPRITEPACK or folder ~= nil) 
    __folder = folder
end

function IO.isSandboxed()
    return IO.__simulateSandbox or (os.getenv == nil)
end

--maybe in a future other file types will be added by codea, but
--for now codea API supports only readImage of png files
--getFileCodea returns an already created image, not raw data
function IO.getFileCodea(fileName)
    local i = string.find(fileName, ".png")
    if not i then
        local err = "default codea api works only with png files"
        return nil, err
    end
    local imgName = string.sub(fileName,1,i-1)
    
    local path
    if __mountPoint == IO.DROPBOX then
        path = "Dropbox:"
        if __folder then
            path = path .. __folder .. "/"
        end
    elseif __mountPoint == IO.DOCUMENTS then
        path = "Documents:"
        if __folder then
            --verify that it's possiblo to do that
            path = path .. __folder .. "/"
        end
    else --Spritepacks
        path = __folder .. ":"
    end
    path = path.. imgName
    --print(path)
    return readImage(path)
end

--get file returns raw data for each type of files
function IO.getFile(fileName)
    
    local home = os.getenv("HOME")
    local path 
    if __mountPoint == IO.DROPBOX then
        path = home.."/Documents/Dropbox.spritepack/"
        if __folder then
            path = path .. __folder .. "/"
        end
    elseif __mountPoint == IO.DOCUMENTS then
        path = home.."/Documents/"
        if __folder then
            path = path .. __folder .. "/"
        end
    else
        path = home.."/Codea.app/SpritePacks/" .. __folder ..
            ".spritepack/"
    end
    path = path .. fileName
    --print(path)
    local file,err = io.open(path,"r")
    if not err then
        local s = file:read("*all")
        io.close(file)
        return s
    else
        return nil, err
    end
end

--]]