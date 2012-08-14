-- DisplayObj

--[[
The DisplayObject class is the base class for all objects that are
rendered on the screen.

- The Display Tree

All displayable objects are organized in a display tree.
Only objects that are part of the display tree will be displayed 
(rendered). The display tree consists of leaf nodes that will be rendered directly to the screen, and of container nodes 
(subclasses of "DisplayObjectContainer"). 

A container is simply a display object that has child nodes,
which can, again, be either leaf nodes or other containers.

A display object has properties that define its position in relation 
to its parent (x, y), as well as its rotation and scaling factors 
(scaleX, scaleY). Use the alpha and  visible properties to make an 
object translucent or invisible. Alpha value are affected by parent 
alpha values, with a multiply factor in the [0..1] range
         
- Transforming coordinates

Within the display tree, each object has its own local coordinate 
system. If you rotate a container, you rotate that coordinate system
and thus all the children of the container.

Sometimes you need to know where a certain point lies relative to 
another coordinate system. That's the purpose of the method 
getTransformationMatrix(). It will create a matrix that represents 
the transformation of a point in one coordinate system to another.
 
- Subclassing

Since DisplayObject is an abstract class, you cannot instantiate it
directly, but have to use one of its subclasses instead.

You will need to implement the following methods when you subclass
DisplayObject:

function DisplayObj:getBounds(targetSpace,resultRect)
function DisplayObj:_innerDraw()
--]]

--used to internally call the getBounds method
local __helperRect = Rect()
--Store locally a reference to an Identity Matrix. Helper to avoid
--to create a new one for each getTransformationMatrix call
local __identityMatrix = matrix()
--used to transform rotation value for rotation matrix
local DEG = math.deg
local PI = math.pi
local PI2 = math.pi * 2

DisplayObj = class(EventDispatcher)
    
function DisplayObj:init()
    EventDispatcher.init(self)
    
    self._members = {
            pivotX = 0, pivotY = 0, x = 0, y = 0, r = 0, 
            scaleX = 1, scaleY = 1
        }
        
    self._flags = {
            bTranslate = false, bRotate = false, bScale = false,
            bPivot = false, bTransform = false
        }
        
    self._alpha = 255
    self._multiplyAlpha = 1
    
    self._visible = true
    self._touchable = true
    
    self._name = nil
end

-- Debug Infos and __tostring redefinition
function DisplayObj:dbgInfo(recursive)
    local sb = StringBuilder()
    sb:writeln("[name = ",self._name,"]")
    sb:writeln("pivot = ",self._members.pivotX,",",self._members.pivotY)
    sb:writeln("position = ",self._members.x,",",self._members.y)
    sb:writeln("scale = ",self._members.scaleX,",",self._members.scaleY)
    sb:writeln("rotation = ",self._members.r)
    sb:writeln("alpha = ",self._alpha)
    sb:writeln("visible = ",self._visible)
    sb:writeln("touchable = ",self._touchable)
            
    return sb:toString(true)
end

--It's possible (but optional) to set a name to a display obj. 
--It can be usefull for debug purpose
function DisplayObj:setName(name)
    self._name = name
end

function DisplayObj:getName()
    return self._name
end

--the method is called by a DisplayObjContainer when the DisplayObj is
--added as child
function DisplayObj:_setParent(parent)
    --assert(not parent or parent:is_a(DisplayObjContainer))
    self.parent = parent
    if parent then
        self:_setMultiplyAlpha(parent:_getMultipliedAlpha())
    else
        self._multiplyAlpha = 1
    end
end

--return the displayObjContainer that contains the displayObj, if any
function DisplayObj:getParent()
    return self.parent
end

function DisplayObj:removeFromParent()
    if self.parent then
        self.parent:removeChild(self)
    end
end

--return the top most displayObjContainer in the display tree
function DisplayObj:getRoot()
    local root = self
    while(root.parent) do
        root = root.parent
    end
    return root
end

-- return the top most displayObjectContainer in the display tree
-- if it's a stage, else nil
function DisplayObj:getStage()
    local root = self:getRoot()
    if root:is_a(Stage) then
        return root
    else
        return nil
    end
end

-- Setter and Getter

function DisplayObj:setVisible(visible)
    self._visible = visible
end

function DisplayObj:isVisible()
   return self._visible
end

function DisplayObj:setTouchable(touchable)
    self._touchable = touchable
end

function DisplayObj:isTouchable()
   return self._touchable
end

--alpha [0..255]
function DisplayObj:setAlpha(a)
    self._alpha = a
end

function DisplayObj:getAlpha()
   return self._alpha
end

--setMultiplyAlpha set the alpha value of the parent container (already
--modified by his current multiplyalpha value)
function DisplayObj:_setMultiplyAlpha(a)
    self._multiplyAlpha = a / 255
end

--getMultipliedAlpha return the [0..1] multiply value provided by 
--the parent container, multiply the [0..255] alpha value of the 
--displayObj
function DisplayObj:_getMultipliedAlpha()
    return self._multiplyAlpha * self._alpha
end

--internal methods. call whenever geometry of the displayObj, locally
--or respect the parent, changes. It also reset the transform matrix
function DisplayObj:_updateGeometry()
    local flags = self._flags
    local members = self._members
    
    flags.bTranslate = members.x ~= 0 or members.y ~= 0
        
    flags.bRotate = members.r ~= 0
    flags.bScale = members.scaleX ~= 1 or members.scaleY ~= 1
        
    flags.bPivot = members.pivotX ~= 0 or members.pivotY ~= 0
    
    flags.bTransform = flags.bTranslate or flags.bRotate or
        flags.bScale or flags.bPivot
        
    self.transformMatrix = nil
end

--All the geometric setter call the _setProp or _setProps method
--that update the inner _members properties and the force the 
--_updateGeometry() call
function DisplayObj:_setProp(n,v)
    if(self._members[n] ~= v) then
        self._members[n] = v
        self:_updateGeometry()
    end
end

function DisplayObj:_setProps(n1,v1,n2,v2)
    if(self._members[n1] ~= v1 or self._members[n2] ~= v2) then
        self._members[n1] = v1
        self._members[n2] = v2
        self:_updateGeometry()
    end
end

function DisplayObj:setPivot(x,y)
    self:_setProps("pivotX",x,"pivotY",y)
end

function DisplayObj:getPivot()
    return self._members.pivotX, self._members.pivotY
end

function DisplayObj:setPivotX(x)
    self:_setProp("pivotX",x)
end

function DisplayObj:getPivotX()
   return self._members.pivotX 
end

function DisplayObj:setPivotY(y)
    self:_setProp("pivotY",y)
end

function DisplayObj:getPivotY()
    return self._members.pivotY
end 


--[[
All the following methods set or get the geometric transformation 
of the object relative to the local coordinates of the parent.
pos and scale have single coords accessors but also coupled (on x 
and y) accessors for performance issues, and "_v2" (vec2) version, 
usefull in different situation (like tweening)
--]]
function DisplayObj:setPos(x,y)
    self:_setProps("x",x,"y",y)
end

function DisplayObj:setPos_v2(v)
    self:setPos(v.x,v.y)
end

function DisplayObj:getPos()
    return self._members.x, self._members.y
end

function DisplayObj:getPos_v2()
    return vec2(self:getPos())
end

function DisplayObj:translate(x,y)
    local x = self._members.x + x 
    local y = self._members.y + y
    self:_setProps("x",x,"y",y)
end

function DisplayObj:setPosX(x)
    self:_setProp("x",x)
end

function DisplayObj:getPosX()
   return self._members.x 
end

function DisplayObj:setPosY(y)
    self:_setProp("y",y)
end

function DisplayObj:getPosY()
    return self._members.y
end 

-- rotation angle is expressed in radians
function DisplayObj:setRotation(r)
    --move into range [-180 deg, +180 deg]
    while (r < -PI) do r = r + PI2 end
    while (r >  PI) do r = r - PI2 end
    self:_setProp("r",r)
end

function DisplayObj:getRotation()
    return self._members.r
end

function DisplayObj:setScale(x,y)
    self:_setProps("scaleX",x,"scaleY",y)
end

function DisplayObj:setScale_v2(v)
    self:setScale(v.x,v.y)
end

function DisplayObj:getScale()
    return self._members.scaleX, self._members.scaleY
end

function DisplayObj:getScale_v2()
    return vec2(self:getScale())
end

function DisplayObj:setScaleX(s)
    self:_setProp("scaleX",s)
end

function DisplayObj:getScaleX()
    return self._members.scaleX
end

function DisplayObj:setScaleY(s)
    self:_setProp("scaleY",s)
end

function DisplayObj:getScaleY()
    return self._members.scaleY
end

function DisplayObj:getWidth()
    return self:getBounds(self.parent,__helperRect).w  
end

function DisplayObj:getHeight()
    return self:getBounds(self.parent,__helperRect).h
end

--[[
    Return a matrix that represents the transformation from the 
    local coordinate system to another.
        
    targetspace can be:
    - self:   return identityMatrix
    - nil:    return transfMatrix related to root
    - ancestor: return related to an obj in that is an ancestor
    of the obj. 
    
    Note: if the passed obj is not an ancestor an error occurs
    
    to have the same functionality of flash/starling is it possible 
    to expose a specific function like "find common ancestor" or 
    similar, calculate the transf matrix of both the objs related 
    to the common ancestor, and use them to calculate the final
    matrix. but being expensive it's preferrable to split the 2
    functionality
--]]
function DisplayObj:getTransformationMatrix(targetSpace)
    
    --assert(not targetSpace or targetSpace:is_a(DisplayObj))
    
    if targetSpace == self then
        return __identitymatrix 
    end
        
    local flags = self._flags
        
    local m = self.transformMatrix or __identityMatrix
       
    if flags.bTransform and not self.transformMatrix then
        local members = self._members
        -- bPivot => translate(pivot)
        -- bTranslate => translate(pos - pivot)
        if flags.bPivot or flags.bTranslate then
            m = m:translate(members.x, members.y)
        end
        if flags.bRotate then
            --rotation angle are in radians but matrix required
            --degrees so need conversion
            m = m:rotate(DEG(members.r))
        end
        if flags.bPivot then
            m = m:translate(-members.pivotX*members.scaleX,
                -members.pivotY*members.scaleY)
        end   
        if flags.bScale then 
            m = m:scale(members.scaleX, members.scaleY)
        end
    end
    
    --cache the current transformMatrix, that became invalid only
    --if some geometric param changes (look at the _updateGeometry()
    --method)
    self.transformMatrix = m
    
    if targetSpace == self.parent then
        --it's valid either if the targetSpace is an ancestor or
        --if targetSpace is nil (so it means root obj)
        return m
    elseif self.parent then
        return m * self.parent:getTransformationMatrix(targetSpace)
    else
        --if parent is null it means that target space is not an
        --ancestor of the current obj, and that's not valid
        error("the targetSpace is not an ancestor of the current obj")
    end
end

--Returns a rectangle that completely encloses the object as it 
--appears in another coordinate system. The method must be override
--by subclasses.
function DisplayObj:getBounds(targetSpace,resultRect)
    error("method must be override")
end

--Transforms a point from the local coordinate system to 
--global coordinates. targetSpace define the destination 
--space of the transformation. If nil is the screenspace
--(== stage)
function DisplayObj:localToGlobal(x,y,targetSpace)
    local m = self:getTransformationMatrix(targetSpace)
    return Matrix.transformPoint(m,x,y)
end

--Transforms a point from global coordinates to the local 
--coordinate system. targetSpace define the source 
--space of the transformation, to where x,y belongs
--If nil is considered to be the screenspace (== stage)
function DisplayObj:globalToLocal(x,y,targetSpace)
    local m = self:getTransformationMatrix(targetSpace)
    local im = m:inverse()
    return Matrix.transformPoint(im,x,y)
end

--the method should be override by DisplayObjContainer to handle
--sub objs hitTest, following inverse render pipeline
--Moreover should be aligned to the starling version where is possible
--to define a "forTouch" param to handle touchable state, and the
--return value should became the target display obj
function DisplayObj:hitTest(x,y,targetSpace,forTouch)
    if not forTouch or (self._visible and self._touchable) then
        local _x,_y
        if targetSpace == self then
            _x,_y = x,y
        else
            _x,_y = self:globalToLocal(x,y,targetSpace)
        end
        local r = self:getBounds(self,__helperRect)
        if r:containsPoint(_x,_y) then
            return self
        end
    end
    return nil
end

--the method must implements concrete draw pf DisplayObj subclasses
function DisplayObj:_innerDraw()
    error("method must be override")
end

--the draw() method apply all the transformation that the displayObj
--need to be correctly placed respect is parent container
function DisplayObj:draw()
    if self._visible then
        local flags = self._flags
        
        if flags.bTransform  then 
            pushMatrix()
            applyMatrix(self:getTransformationMatrix(self.parent))
        end
        
        self:_innerDraw()
        
        if flags.bTransform then 
            popMatrix() 
        end
    end
end