 -- Texture 

--[[
A texture stores the information that represents an image. It cannot 
be added to the display list directly; instead it has to be mapped 
into a display object, that is the class "Image".
--]]

Texture = class()

--Return the subtexture of the given texture, based on region definition
--if region is (0,0,1,1) then return texture
function Texture.fromTexture(texture,region)
    if region.x == 0 and region.y == 0 and 
        region.w == 1 and region.h == 1 then
            return texture
    else
        return SubTexture(texture,region)
    end
end

--[[
create a Texture starting from a displayObj
if the displayObj is an image, return the displayObj
if the displayObj is a generic displayObj, create a new
image(displayObj.width, displayObj.heiht), set it as context and
draw the displayObj calling _innerDraw method that draw without
applying transformations.
--]]
function Texture.fromDisplayObj(displayObj)
    assert(displayObj:is_a(DisplayObj))
    if(displayObj:is_a(Image)) then
        return displayObj.texture
    end
    local bounds = displayObj:getBounds(displayObj)
    local img = image(bounds.w,bounds.h)
    
    setContext(img)
    
    if(bounds.x ~= 0 or bounds.y ~= 0) then
        pushMatrix()
        local m = matrix():translate(-bounds.x,-bounds.y)
        applyMatrix(m)
    end

    displayObj:_innerDraw()
    
    if(bounds.x ~= 0 or bounds.y ~= 0) then
        popMatrix()
    end
    setContext()
    
    return Texture(img)
end

--func should draw something in the (0,0,w,h) rect
function Texture.fromFunction(func,w,h)
    local img = image(w,h)
    setContext(img)
    func()
    setContext()
    return Texture(img)
end

-- Texture methods

--accepts images or string name as SpritePackName:ImageResource
function Texture:init(textureData)
    self.textureData = type(textureData) == 'string' and
        readImage(textureData) or textureData
    
    self.width = self.textureData.width
    self.height = self.textureData.height
    
    self.region = Rect(0,0,1,1)
    self.rect = Rect(0,0,self.width,self.height)
end

--return the base raw image
function Texture:image()
    return self.textureData
end

--[[
pixel collision hitTest between 2 textures
check Utils.imageHitTest for specifications

-Todo: improve this function making inner test on subarea of 
each codea image insetad of creating new codea images and then
rely on imageHitTest
--]]
function Texture:hitTest(p1,a1,texture2,p2,a2)
    return imageHitTest(self:image(),p1,a1,
        texture2:image(),p2,a2)
end