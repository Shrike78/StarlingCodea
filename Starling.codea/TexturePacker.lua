--TexturePacker exported files parser

--[[
There are several ways to create a texture atlas. 

One solution is the commercial software Texture Packer, that can 
export atlas descriptor for different framework.

Texture Packer namespace provides parsing functions for some
of this descriptors.
--]]

TexturePacker = {}

--[[
Parser for the Sparrow/Starling xml descriptor
The descriptor must be an XmlNode and the xml should be in the form:

<TextureAtlas imagePath='atlas.png'>
    <SubTexture name='texture_1' x='0'  y='0' width='50' height='50'/>
    <SubTexture name='texture_2' x='50' y='0' width='20' height='30'/>
</TextureAtlas>

It doesn't support for now rotation and trim
--]]
function TexturePacker.parseSparrowFormat(descriptor)
    --assert(descriptor:is_a(XmlNode))
    --[[
    parse config file for a specific textureset
    each item is a texture, with a symbolic name, a 
    parent texture and uv map. don't handle trim and 
    rotation. 
    --]]
    
    local imgName = descriptor:getAttribute("imagePath")
    local texture = Assets.getTexture(imgName)
    
    local atlas = TextureAtlas(texture)
               
    for _,subTex in pairs(descriptor:getChildren("SubTexture")) do   
        local name = subTex:getAttribute("name")
        --divide for width/height to have a [0..1] range
        local x = subTex:getAttributeN("x") / texture.width
        local y = subTex:getAttributeN("y") / texture.height
        local w = subTex:getAttributeN("width") / texture.width
        local h = subTex:getAttributeN("height") / texture.height
        
        --Sparrow/Starling work with (0,0) as top left
        --Codea with (0,0) as bottom left
        local region = Rect(x, 1-(y+h), w, h)
        atlas:addRegion(name,region)
    end
    return atlas
end

--[[
--return {
atlasDescriptor = {
    texture = 'atlas.png',
    frames = {
                {
                    name = "texture_1.png",
                    spriteColorRect = { x = 0, y = 0, 
                        width = 40, height = 40 },               
                    uvRect = { u0 = 0.015625, v0 = 0.0078125, 
                        u1 = 0.640625, v1 = 0.320312 },    
                    spriteSourceSize = { width = 40, height = 40 },
                    spriteTrimmed = false,
                    textureRotated = false
                },
                {
                    name = "texture_2.png",
                    spriteColorRect = { x = 0, y = 0, 
                        width = 40, height = 40 },
                    uvRect = { u0 = 0.015625, v0 = 0.328125, 
                        u1 = 0.640625, v1 = 0.640625 },
                    spriteSourceSize = { width = 40, height = 40 },
                    spriteTrimmed = false,
                    textureRotated = false
                },
            }
    }
    --]]
function TexturePacker.parseMoaiFormat(descriptor)
    
    local imgName = descriptor.texture
    local texture = Assets.getTexture(imgName)
    
    local atlas = TextureAtlas(texture)
               
    for _,subTex in pairs(descriptor.frames) do
        --remove png suffix to be coherent with sparrow format
        local name = string.removeSuffix(subTex.name,".png")
        local x = subTex.uvRect.u0
        local y = subTex.uvRect.v0
        local w = subTex.uvRect.u1 - x
        local h = subTex.uvRect.v1 - y
        
        --Sparrow/Starling work with (0,0) as top left
        --Codea with (0,0) as bottom left
        local region = Rect(x, 1-(y+h), w, h)
        atlas:addRegion(name,region)
    end
    return atlas
end
