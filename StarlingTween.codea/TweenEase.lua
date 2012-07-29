-- TweenEase

--[[
A TweenEase animates numeric properties of objects. It uses different
transition functions to give the animations various styles.

The primary use of this class is to do standard animations like 
movement, fading, rotation, etc. But there are no limits on what to 
animate; as long as the property you want to animate is numeric, the tween can handle it. For a list of available Transition types, look 
at the "Transitions" class.

The property can be directly a numeric key of a table/class, or a 
couple of setter and getter function/method of a table/class
    
usage:

e = Tween.ease(obj,tweenTime,Transition.LINEAR)
e:animate("x",endValue)
e:animateEx(obj.setR,endValue)
--]]

local TweenEase = class(Tween)
Tween.ease = TweenEase

function TweenEase:init(target,time,transitionName)
    assert(transitionName,"a valid transition name must be provided")
    Tween.init(self)
    assert(time>0,"A tween must have a valid time")
    self.target = target
    self.totalTime = math.max(0.0001, time)
    self.transition = Transition.getTransition(transitionName)
    assert(self.transition,
        transitionName.." is not a registered transition")
             
    self.properties = {}
    self.setters = {}
    self.tweenInfo = {}
end


--[[
Animates the property of an object to a target value. 
Is it possible to call this method multiple times on one tween, 
to animate different properties.

- endValue is the value to which property will tween with a curve and 
in a time configured when the tween was created.

- roundToInt is optional, and if true force updated propery values
to be rounded to int values
--]]
function TweenEase:animate(property, endValue, roundToInt)
    assert(self.target[property],property..
        " is not a property of the target of this tween")
    table.insert(self.properties,property)
    self.tweenInfo[property] = {
            startValue = nil,
            endValue = endValue,
            roundToInt = roundToInt or false
    }
    return self
end

--Work as animate but instead of a property it receives a pair
--of setter and getter methods
function TweenEase:animateEx(setter, getter, endValue, roundToInt)
    table.insert(self.setters,setter)
    self.tweenInfo[setter] = {
            getter = getter,
            startValue = nil,
            endValue = endValue,
            roundToInt = roundToInt or false
    }
    return self
end

--onStart initialize start values of each tweened property
function TweenEase:onStart()
    for _,property in pairs(self.properties) do
        local info = self.tweenInfo[property]
        info.startValue = self.target[property]
    end
    for _,setter in pairs(self.setters) do
        local info = self.tweenInfo[setter]
        info.startValue = info.getter(self.target)
    end
end

local round = math.round
local min = math.min

function TweenEase:onUpdate(deltaTime)
    
    local ratio = min(self.totalTime, self.currentTime) / 
        self.totalTime
    
    function _getValue(hash,ratio)
        local info = self.tweenInfo[hash]
        local startValue = info.startValue
        local endValue = info.endValue
        local delta = endValue - startValue
            
        local currentValue = startValue + self.transition(ratio) * delta
        if (info.roundToInt) then
            currentValue = round(currentValue)
        end
        return currentValue
    end

    for _,property in pairs(self.properties) do
        self.target[property] = _getValue(property,ratio)
    end
    
    for _,setter in pairs(self.setters) do
        setter(self.target, _getValue(setter,ratio))
    end
end

function TweenEase:isCompleted()
    return (self.currentTime >= self.totalTime)
end
