-- Image

--[[ 
An Image is the Starling equivalent of Flash's Bitmap class. 
Instead of BitmapData, Starling uses textures to represent the 
pixels of an image. To display a texture, you have to map it onto 
a quad of a mesh and that's what the Image class is for.

It's possible to set a color. For each pixel, the resulting color 
will be the result of the multiplication of the color of the texture 
with the color of the quad. That allows to easily tint textures with 
a certain color. 

--]]
Image = class(Quad)

function Image:init(texture, pivotMode)
    Quad.init(self,texture.width,texture.height,pivotMode)
    self:setTexture(texture)
end

-- protected and friend methods
function Image:_setParent(parent)
    Quad._setParent(self,parent)
    
    if self.meshdata then
        local uv = self.texture.region
        self.meshdata.mesh:setRectTex(self.meshdata.idx,
            uv.x,uv.y,uv.w,uv.h)
    end
end


-- public 

--the clone method return a new Image that shares the same texture
--of the original image. It's possible to clone also
--pivot mode / position
function Image:clone(bClonePivot)
    if not bClonePivot then
        return Image(self.texture)
    else
        local obj = Image(self.texture,self._pivotMode)
        if self._pivotMode == PivotMode.CUSTOM then
            obj:setPivot(self:getPivot())
        end
        return obj
    end
end

--[[
If the new and the old textures shared the same textureData
the switch is just an uv switch, else a full texture switch

It would be preferrable that all the textures that can 
be assigned to a specific image belongs to the same 
texture atlas, to avoid texturedata switch at container level
that requires mesh quads pool management, possible creation of 
a new quad, a forced updategeometry, ecc. 
--]]
function Image:setTexture(texture)
    if self.texture ~= texture then
        
        --if first set (called by init) or texture switch between
        --subtexture of the same texture atlas, an update is
        --required only if the shape changes
        local bUpdateGeometry = not self.texture or 
            (self.texture.width ~= texture.width)
        
        
            
        --if attached to a displayObjContainer
        if self.meshdata then
            local prevTextureData = self.texture.textureData
            self.texture = texture
            if prevTextureData ~= texture.textureData then
                self.parent:_releaseMeshData(self.meshdata)
                self.meshdata = self.parent:_getMeshData(self)
                --that means that pivot and shape are the same,
                --but an update is required because the new 
                --quad provided by parent is a 0,0,0,0 rect
                if not bUpdateGeometry then
                    self:_updateGeometry()
                end
            end
            
            local uv = texture.region
            self.meshdata.mesh:setRectTex(self.meshdata.idx,
                uv.x,uv.y,uv.w,uv.h)
        else
            self.texture = texture
        end
        
        
        if bUpdateGeometry then
            self._rectMatrix[3] = texture.width
            self._rectMatrix[4] = texture.width
            self._rectMatrix[5] = texture.height
            self._rectMatrix[8] = texture.height
            
            if (self.pivotModeFunction) then
                self:pivotModeFunction()
            else
                self:_updateGeometry()
            end
        end
    end
end