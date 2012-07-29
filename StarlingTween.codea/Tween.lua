-- Tween

--[[
A tween is an IAnimatable object used to animate another object
properties. Tween is a base abstract class. It exposes also static functions in order to create comcrete tweens. Each specific tween 
class must implement onStart, onUpdate, onComplete and isComplete
methods in order to define start,update,complete (that means reset) 
logic and to define finish condition.

Specific tweens are Ease, Bezier. Tweens can also be delayed, looped
or grouped in parallel or in sequence. A combination of more tweens 
is a tween itself.

Tween extends EventDispatcher and use Event.REMOVE_FROM_JUGGLER to 
communicate that the tween is completed to his container, that can 
be a composite tween or a juggler

A tween will only be executed if its "advanceTime" method is executed,
so the best way is to add the tween object to a juggler that 
will do that for you, and will remove the tween when it is finished.
--]]

Tween = class(EventDispatcher,IAnimatable)

function Tween:init()
    EventDispatcher.init(self)
    self.removeEvent = Event(Event.REMOVE_FROM_JUGGLER)
    self.currentTime = 0
end

--retrieve the time that has passed since the tween is started.
--if the tween is already completed return 0
function Tween:getElapsedTime()
    return self.currentTime
end

--Set a callback function with arguments that will be called 
--when the tween starts. 
function Tween:callOnStart(func ,...)
    self._onStart = func
    self._onStartArgs = {...}
    return self
end

--Set a callback function with arguments that will be called 
--each advanceTime
function Tween:callOnUpdate(func ,...)
    self._onUpdate = func
    self._onUpdateArgs = {...}
    return self
end

--Set a callback function with arguments that will be called 
--when the tween is completed. 
function Tween:callOnComplete(func ,...)
    self._onComplete = func
    self._onCompleteArgs = {...}
    return self
end

--when override add initialization logic if needed
function Tween:onStart()
end

--when override add update logic if needed
function Tween:onUpdate(deltaTime)
end

--when override add reset logic if needed
function Tween:onComplete()
end

--this function must be implemented by any class that implements Tween
--because each Tween need an ending clause
function Tween:isCompleted()
    error("Tween is an abstract class. override me")
end


--generic tween update function. 
function Tween:advanceTime(deltaTime)
    if self.currentTime == 0 then
        self:onStart()
        if self._onStart then
            Callbacks.callFunction(self._onStart,self._onStartArgs)
        end
    end
    
    self.currentTime = self.currentTime + deltaTime
    self:onUpdate(deltaTime)
    if self._onUpdate then
        Callbacks.callFunction(self._onUpdate,self._onUpdateArgs)
    end
    
    if self:isCompleted() then
        self.currentTime = 0
        self:onComplete()
        if self._onComplete then
            Callbacks.callFunction(self._onComplete, 
                self._onCompleteArgs)
        end
        self:dispatchEvent(self.removeEvent)
    end
end

