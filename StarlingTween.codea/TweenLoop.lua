-- TweenLoop

--[[
TweenLoop is used to repeat n times (or infinite times) a specific 
tween

usage:

l = Tween.loop(t,2) --repeat t 2 times
l = Tween.loop(t,-1) --repeat t infinite times
--]]

local TweenLoop = class(Tween)
Tween.loop = TweenLoop

-- tween: the tween to repeat
-- repeatNum: positive number or negative value for infinite repetition
function TweenLoop:init(tween,repeatNum)
    Tween.init(self)
    assert(tween:is_a(Tween))
    assert(repeatNum and repeatNum~= 0,"repeatNum cannot be null or 0")
    self.tween = tween
    tween:addEventListener(Event.REMOVE_FROM_JUGGLER,
                self.onRemoveEvent,self)
    self.repeatCount = repeatNum
    self.repeatNum = repeatNum
end

function TweenLoop:onRemoveEvent(e)
    if self.repeatCount > 0 then
        self.repeatCount = self.repeatCount - 1
    end
end

function TweenLoop:onUpdate(deltaTime)
    self.tween:advanceTime(deltaTime)
end

function TweenLoop:onComplete()
    self.repeatCount = self.repeatNum
end

function TweenLoop:isCompleted()
    return (self.repeatCount == 0)
end
