-- DisplayObjContainer

--[[
A DisplayObjectContainer represents a collection of display objects.
It is the base class of all display objects that act as a container 
for other objects. By maintaining an ordered list of children, it
defines the back-to-front positioning of the children within the 
display tree.

A container does not a have size in itself. The width and height 
properties represent the extents of its children. 

It can handle 2 type of displayObj: geometrical shapes or anyway objs
that have their own draw logic, and images tha are not handled 
directly, but remapped on quad of meshes shared between images with 
the same texture (or super texture when speaking of texture atlas)

- Adding and removing children

The class defines methods that allow you to add or remove children.

When you add a child, it will be added at the frontmost position, 
possibly occluding a child that was added before.

That is not always true for images/mesh quads: to optimize mesh usage
all the quads are managed by a pool so, once an image is removed
from the container, the relative quad is collapsed and stored in the 
pool, and used again for the next image added to the container (with 
the same texture). In that way an Image added last can be draw before 
image added previously. The only way to guarantee mesh draw order is 
to avoid remove operations
--]]

DisplayObjContainer = class(DisplayObj)

function DisplayObjContainer:init()
    DisplayObj.init(self)
    -- you can accept and set parameters here
    self._meshes = {}
    self._quadPool = {}
    --images and displayObjs are in 2 different list for several 
    --reason, including performance issues when drawing, avoid 
    --this way to traverso also images that are instead rendered 
    --through mesh:draw()
    self._quads = {}
    self._displayObjs = {}
    
    --used to cicle on all containers
    self._displayLists = {self._displayObjs, self._quads}
                                
    self._hittable = false
    self._numChildren = 0
end

-- Debug Infos and __tostring redefinition
function DisplayObjContainer:dbgInfo(recursive)
    local sb = StringBuilder()
    sb:write(DisplayObj.dbgInfo(self,recursive))
    sb:writeln("#quads = ",#self._quads)
    sb:writeln("#displayObjs = ",#self._displayObjs)
    local counter = 1
    for i,v in pairs(self._meshes) do
        local unusedQuads = self._quadPool[i] and 
            #self._quadPool[i] or 0
        local s = string.format("mesh[%d]: %s, %d quads, %d unused",
           counter, tostring(i), #v.vertices/6,unusedQuads)
        counter = counter + 1
        sb:writeln(s)
    end
    sb:writeln()
    if recursive then 
        for _,v in ipairs(self._displayObjs) do
            if v:is_a(DisplayObjContainer) then
                sb:writeln(v:dbgInfo(true))
            end
        end
    end
    return sb:toString(true)
end


--The addChild method check the type of the obj and store it 
--in a specific list. Images needs to be handled in a different way
--then other displayObj or container.
function DisplayObjContainer:addChild(obj)

    local objList = obj:is_a(Quad) and self._quads or self._displayObjs
--[[
    assert(obj:is_a(DisplayObj), debug.getinfo(1,"n").name .. 
        " obj is not a DisplayObj")
        
    assert(obj ~= self, debug.getinfo(1,"n").name .. 
        "an obj can't be add to itself")
    
    assert(table.find(objList,obj)==0, debug.getinfo(1,"n").name .. 
        " obj already contained")
--]]
    --force to remove obj from previous container, cause an obj can 
    --have only one container at once
    if(obj.parent) then
        obj.parent:removeChild(obj)
    end
    
    table.insert(objList,obj) 
    obj:_setParent(self)
    self._numChildren = self._numChildren + 1
end

function DisplayObjContainer:removeChild(obj)
    local objList = obj:is_a(Quad) and self._quads or self._displayObjs

    local pos = table.find(objList,obj)
    
    --assert(pos>0, debug.getinfo(1,"n").name .. ": obj is not contained by this container")
    
    if(pos)then
        table.remove(objList,pos)
        obj:_setParent(nil)
        self._numChildren = self._numChildren - 1
    end

end

function DisplayObjContainer:_getMeshData(quad)
--[[
    assert(quad:is_a(Quad), debug.getinfo(1,"n").name .. 
        " quad is not an Quad")
        
    assert(table.find(self._quads,quad)>0, debug.getinfo(1,"n").name .. 
        " quad is not contained")
--]]
    local bImage = quad:is_a(Image)
    
    local textData = bImage and quad.texture.textureData or "_quad_"
    local cmesh = self._meshes[textData]
 
    if cmesh then
        if self._quadPool[cmesh] and #self._quadPool[cmesh] then
            local meshdata = table.remove(self._quadPool[cmesh])
            return meshdata
        end
    else
        self._meshes[textData] = mesh()
        if bImage then
            self._meshes[textData].texture = textData
        end
    end
    local idx = self._meshes[textData]:addRect(0,0,0,0)
    -- temp fix for 500th quad problem.... remove after next release
    -- of codea!
    if (idx % 500) == 0 then
        idx = self._meshes[textData]:addRect(0,0,0,0)
    end
    return MeshData(self._meshes[textData], idx)
end

function DisplayObjContainer:_releaseMeshData(meshdata)
    meshdata.mesh:setRectTex(meshdata.idx, 0,0,0,0)
    if not(self._quadPool[meshdata.mesh]) then 
        self._quadPool[meshdata.mesh] = {}
    end
    table.insert(self._quadPool[meshdata.mesh], meshdata)
end

function DisplayObjContainer:setAlpha(a)
    --DisplayObj.setAlpha(self,a)
    self._alpha = a
    self:_updateChildrenAlpha()
end

function DisplayObjContainer:_setMultiplyAlpha(a)
    --DisplayObj.setMultiplyAlpha(self,a)
    self._multiplyAlpha = a / 255
    self:_updateChildrenAlpha()
end

--propagate alpha to all children
function DisplayObjContainer:_updateChildrenAlpha()
    local a = self._alpha * self._multiplyAlpha
    
    for _,displayList in ipairs(self._displayLists) do
        for _,v in pairs(displayList) do
            v:_setMultiplyAlpha(a)
        end
    end
end


--By default the hitTet over a DisplayObjContainer is an hitTest over
--all its children. It's possible anyway to set itself as target of
--an hitTest, without going deep in the displayList
function DisplayObjContainer:setHittable(hittable)
    self._hittable = hittable
end

function DisplayObjContainer:isHittable()
    return self._hittable
end

--[[
If the container is set as hittable, the hitTest will be done only
on its own boundary without hittesting all the children, and the 
resulting target will be itself. If not hittable instead, the hitTest
will bendone on children, ustarting from then topmost 
displayObjContainer.

NB
A known issue of hitTest is related to quads. While 
DisplayObjContainers and DisplayObjs are rendered with the same 
order they were inserted, that's not true for quads. HitTest on quads
can therefore produce unexpected results.
--]]
function DisplayObjContainer:hitTest(x,y,targetSpace,forTouch)
    if self._hittable then
        return DisplayObj.hitTest(self,x,y,targetSpace,forTouch)   
    elseif not forTouch or (self._visible and self._touchable) then
        local _x,_y
        if targetSpace == self then
            _x,_y = x,y
        else
            _x,_y = self:globalToLocal(x,y,targetSpace)
        end
        local target = nil
        for _,displayList in ipairs(self._displayLists) do
            for i = #displayList,1,-1 do
                target = displayList[i]:hitTest(_x,_y,self,forTouch)
                if target then 
                    return target
                end
            end
        end
    end
    return nil
end

local min = math.min
local max = math.max
local MAX_VALUE = math.huge
local MIN_VALUE = -math.huge

function DisplayObjContainer:getBounds(targetSpace,resultRect)
    local r = resultRect or Rect()
    
    if self._numChildren == 0 then
        r.x,r.y,r.w,r.h = 0,0,0,0
    else
        local xmin = MAX_VALUE
        local xmax = MIN_VALUE
        local ymin = MAX_VALUE
        local ymax = MIN_VALUE
        for _,displayList in ipairs(self._displayLists) do
            for _,obj in ipairs(displayList) do
                r = obj:getBounds(targetSpace,r)
                xmin = min(xmin,r.x)
                xmax = max(xmax,r.x+r.w)
                ymin = min(ymin,r.y)
                ymax = max(ymax,r.y+r.h)
            end
        end
        r.x,r.y,r.w,r.h = xmin,ymin,(xmax-xmin),(ymax-ymin)
    end
    return r
end

--[[
The render pipeline for a DisplayObjContainer is:
- render all the quads (insertion order is not respected)
- render all the DisplayObjs (following insertion order)
--]]
function DisplayObjContainer:_innerDraw()
    for _,mesh in pairs(self._meshes) do
        mesh:draw()
    end
    
    for _,displayObj in ipairs(self._displayObjs) do
        if displayObj._visible then
            displayObj:draw()
        end
    end
end