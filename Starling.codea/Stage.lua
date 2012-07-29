-- Stage

Stage = class(DisplayObjContainer)

function Stage:init()
    DisplayObjContainer.init(self)
    self.bgcolor = color(0,0,0,255)
end

function Stage:_setProp(n,v)
    error("It's not possible to change "..n.." property of a Stage")
end

function Stage:_setProps(n1,v1,n2,v2)
    error("It's not possible to change "..n1..","..n2..
        " properties of a Stage")
end

function Stage:_setParent(parent)
    error("Stage cannot be child of another DisplayObjContainer")
end

function Stage:setBgColor(bgcolor)
    self.bgcolor = bgcolor
end

function Stage:getBgColor(bgcolor)
    return self.bgcolor
end

function Stage:draw()
    if self._visible then
        
        if self.bgcolor then
            background(self.bgcolor)
        end
        self:_innerDraw()
    end
end