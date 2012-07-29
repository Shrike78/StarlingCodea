-- Assets

--[[
Assets namespace provides facilities to load and cache different 
type of resources.
--]]

Assets = {}

local __imageCache = {}
local __xmlCache = {}

--return a codea image() loaded by a file. cache it once loaded 
--first time
function Assets.getRawImage(fileName)
    if not __imageCache[fileName] then
        local img
        if not IO.isSandboxed() then
            local data, err = IO.getFile(fileName)
            if not data then
                return nil, err
            end
            img = image(data)
        else
            img = IO.getFileCodea(fileName)
        end
        __imageCache[fileName] = img
    end
    return __imageCache[fileName]
end

--return a Texture starting from a Codea Image, amd cache it once 
--created first time
function Assets.getTexture(fileName)
    return Texture(Assets.getRawImage(fileName))
end

--load, and parse (and cache the result string) an xml.
--return an XmlNode wrapping the parsed xml.
--NB: XmlNodes are not cached
function Assets.getXml(fileName)
    if not __xmlCache[fileName] then
        local data, err = IO.getFile(fileName)
        if not data then 
            return nil, err
        end
        __xmlCache[fileName] = data
    end
    return XmlNode.fromString(__xmlCache[fileName])
end

--clear all the cached objs
function Assets.clearCache()
    table.clear(__imageCache)
    table.clear(__xmlCache)
    table.clear(__textureCache)
end