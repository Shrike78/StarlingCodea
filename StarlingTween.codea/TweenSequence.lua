-- TweenSequence

--[[
A TweenSequence is a group of tween executed sequentially.

usage:

p = Tween.sequence(t1,t2,t3)

where t1,t2,t3 are different tweens
--]]

local TweenSequence = class(Tween)
Tween.sequence = TweenSequence

function TweenSequence:init(...)
    Tween.init(self)
    local type = type
    local args = {...}
    assert(#args>1,"a tween list must contains at least 2 elements")
    self.list = {}
    for _,v in pairs(args) do
        assert(v:is_a(Tween))
        v:addEventListener(Event.REMOVE_FROM_JUGGLER,
                    self.onRemoveEvent,self)
        table.insert(self.list,v)
    end
    self.currentIndex = 1
end


function TweenSequence:onRemoveEvent(e)
    self.currentIndex = self.currentIndex + 1
end

function TweenSequence:onUpdate(deltaTime)
    self.list[self.currentIndex]:advanceTime(deltaTime)
end

function TweenSequence:onComplete()
    self.currentIndex = 1
end

function TweenSequence:isCompleted()
    return (self.currentIndex > #self.list)
end
