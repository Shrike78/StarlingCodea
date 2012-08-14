-- Quad

--[[ 

A Quad represents a rectangle with a uniform color or a color gradient.
It's possible to set one color per vertex. The colors will smoothly 
fade into each other over the area of the quad. To display a simple 
linear color gradient, assign one color to vertices 0 and 1 and 
another color to vertices 2 and 3. 

The indices of the vertices are arranged like this:

1 - 4
| \ |
2 - 3
    
Quads allows different pivotMode:

    "CUSTOM"      : manually set x,y coordinates
    "BOTTOM_LEFT" : the pivotPoint is always the bottom left point of 
                    the bound rect
    "TOP_LEFT"    : the pivotPoint is always the top left point of the 
                    bound rect
    "CENTER"      : the pivotPoint is always the center point of the 
                    bound rect
                    
PivotMode.CENTER is the most performant mode (because it relies on
mesh:setRect) and for this reason is the default mode.
--]]

PivotMode = {
    CUSTOM = 1,
    BOTTOM_LEFT = 2,
    TOP_LEFT = 3,
    CENTER = 4, 
}

Quad = class(DisplayObj)

function Quad:init(width,height,pivotMode)
    DisplayObj.init(self)

    --use a matrix to store rect info
    --                        p1      p2    p3        p4
    self._rectMatrix = matrix(0,      0,    width,    width,
                              height, 0,    0,        height,
                              0,      0,    0,        0,
                              1,      1,    1,        1)
            
    self._colors = {}
    for i=1,4 do
        --it's not necessary to call updateColor
        -- because this is the default color for a new rect
        self._colors[i] = color(255, 255, 255, 255)
    end
    local pivotMode = pivotMode or PivotMode.CENTER
    self:setPivotMode(pivotMode)
end

-- protected and friend methods
function Quad:_setParent(parent)
    if (not parent and self.parent) then
        self.parent:_releaseMeshData(self.meshdata)
    end
    
    self.parent = parent
   
    if self.parent then
        self.meshdata = self.parent:_getMeshData(self)
        self:_updateGeometry()
        self:_setMultiplyAlpha(parent:_getMultipliedAlpha())
        self:_updateColor()
    else
        self.meshdata = nil
    end   
end

--The pivot can be custom (by calling setPivot/setPivotX,Y) or
--fixed (center,top_left,bottom_left)
--to handle fixed pivot, each time a geometric change happens
--there must be a call to a specific function that reset the pivot, 
--depending on the new shape of the object.
function Quad:_pivotModeC()
    self:_setProps("pivotX",self:getWidth()/2, 
        "pivotY",self:getHeight()/2)
end

function Quad:_pivotModeTL()
    self:_setProps("pivotX",0, "pivotY",self:getHeight())
end

--ordered by PivotMode enum values
local __pivotModeFunctions = {
        nil,                  --"CUSTOM"
        nil,                  --"BOTTOM_LEFT"
        Quad._pivotModeTL,    --"TOP_LEFT"
        Quad._pivotModeC      --"CENTER"
    }
        
function Quad:setPivotMode(pivotMode)
    --assert(pivotMode>0 and pivotMode <= #__pivotModeFunctions)
    self._pivotMode = pivotMode

    self.pivotModeFunction = __pivotModeFunctions[pivotMode]
    if pivotMode == PivotMode.BOTTOM_LEFT then
        self:_setProps("pivotX",0, "pivotY",0)
    end
    if (self.pivotModeFunction) then
        self:pivotModeFunction()
    end
end

function Quad:getPivotMode()
    return self._pivotMode
end

function Quad:setPivot(x,y)
    self:setPivotMode(PivotMode.CUSTOM)
    self:_setProps("pivotX",x,"pivotY",y)
end

function Quad:setPivotX(x)
    self:setPivotMode(PivotMode.CUSTOM)
    self:_setProp("pivotX",x)
end

function Quad:setPivotY(y)
    self:setPivotMode(PivotMode.CUSTOM)
    self:_setProp("pivotY",y)
end

function Quad:_updateGeometry()
    DisplayObj._updateGeometry(self)
    
    if self.meshdata then
        
        if not self._visible then
            self.meshdata.mesh:setRect(self.meshdata.idx,
                0,0,0,0)
            return
        end
        
        if self._pivotMode ~= PivotMode.CENTER and self._flags.bRotate 
            --or true
            then
                
            local m = self:getTransformationMatrix(self.parent)
            local tm =  m:transpose() * self._rectMatrix
            
            local idx = (self.meshdata.idx - 1) * 6
            local mesh = self.meshdata.mesh
            mesh:vertex(idx + 1, tm[1],tm[5])
            mesh:vertex(idx + 2, tm[2],tm[6])
            mesh:vertex(idx + 3, tm[3],tm[7])
            mesh:vertex(idx + 4, tm[1],tm[5])
            mesh:vertex(idx + 5, tm[3],tm[7])
            mesh:vertex(idx + 6, tm[4],tm[8])
            
        else
            local sx = self._members.scaleX
            local sy = self._members.scaleY
            local w = self._rectMatrix[3] * sx
            local h = self._rectMatrix[5] * sy
            
            if self._pivotMode == PivotMode.CENTER then
                self.meshdata.mesh:setRect(self.meshdata.idx,
                    self._members.x,
                    self._members.y,
                    w,h,
                    self._members.r)
            else
                --not centered and not rotate
                local x = self._members.x - self._members.pivotX * 
                    sx + w/2
                local y = self._members.y - self._members.pivotY *
                    sy + h/2
                    
                self.meshdata.mesh:setRect(self.meshdata.idx,
                    x,y,w,h)
            end
        end
    end
end

function Quad:_updateColor()
    if self.meshdata then
        
        local idx = (self.meshdata.idx - 1) * 6 + 1
        local mesh = self.meshdata.mesh
        local c = self._colors[1]
        mesh:color(idx,c.r,c.g,c.b,c.a*self._multiplyAlpha)
        mesh:color(idx+3,c.r,c.g,c.b,c.a*self._multiplyAlpha)
        
        c = self._colors[2]
        mesh:color(idx+1,c.r,c.g,c.b,c.a*self._multiplyAlpha)
        
        c = self._colors[3]
        mesh:color(idx+2,c.r,c.g,c.b,c.a*self._multiplyAlpha)
        mesh:color(idx+4,c.r,c.g,c.b,c.a*self._multiplyAlpha)
        
        c = self._colors[4]
        mesh:color(idx+5,c.r,c.g,c.b,c.a*self._multiplyAlpha)
    end
end

-- public Setter and Getter
function Quad:setColor(r,g,b)
    local _r = g and r or r.r
    local _g = g and g or r.g
    local _b = g and b or r.b
    
    for i = 1,4 do
        self._colors[i].r = _r
        self._colors[i].g = _g
        self._colors[i].b = _b
    end
    self:_updateColor()
end

function Quad:getColor()
    local c = self._colors[1]
    return c.r,c.g,c.b
end

function Quad:setVertexColor(v,r,g,b) 
    local _r = g and r or r.r
    local _g = g and g or r.g
    local _b = g and b or r.b
    
    self._colors[v].r = _r
    self._colors[v].g = _g
    self._colors[v].b = _b
    if self.meshdata then
        self.meshdata:setVertexColor(v,_r,_g,_b,
            self._colors[v].a * self._multiplyAlpha)
    end
end

function Quad:getVertexColor(v)
   return self._colors[v]
end

function Quad:_setMultiplyAlpha(a)
    self._multiplyAlpha = a / 255
    self:_updateColor()
end

function Quad:_getMultipliedAlpha()
   return self._multiplyAlpha * self._colors[1].a
end

function Quad:setAlpha(a)
    for i = 1,4 do
        self._colors[i].a = a
    end
    self:_updateColor()
end

function Quad:getAlpha()
   return self._colors[1].a
end

function Quad:setVertexAlpha(v,a) 
    self._colors[v].a = a
    if self.meshdata then
        self.meshdata:setVertexColor(v,
            self._colors[v].r,
            self._colors[v].g,
            self._colors[v].b,
            a * self._multiplyAlpha)
    end
end

function Quad:getVertexAlpha(v)
   return self._colors[v].a
end

function Quad:setVisible(bVisible)
    if bVisible ~= self._visible then
        DisplayObj.setVisible(self,bVisible)
        self:_updateGeometry()
    end
end

local min = math.min
local max = math.max
local MAX_VALUE = math.huge
local MIN_VALUE = -math.huge

function Quad:getBounds(targetSpace,resultRect)
    local r = resultRect or Rect()
    if targetSpace ~= self then
        local m = self:getTransformationMatrix(targetSpace)
        local xmin = MAX_VALUE
        local xmax = MIN_VALUE
        local ymin = MAX_VALUE
        local ymax = MIN_VALUE
        local x,y
        
        local tm =  m:transpose() * self._rectMatrix
        
        for i = 1,4 do
            x,y = tm[i], tm[i+4]       
            xmin = min(xmin,x)
            xmax = max(xmax,x)
            ymin = min(ymin,y)
            ymax = max(ymax,y)
           
        end
        r.x,r.y,r.w,r.h = xmin,ymin,(xmax-xmin),(ymax-ymin)
    else
        r.x,r.y,r.w,r.h = 0,0,self._rectMatrix[3],self._rectMatrix[5]
    end
    return r
end

function Quad:_innerDraw()
    error("Quads cannot be directly drawn")
end