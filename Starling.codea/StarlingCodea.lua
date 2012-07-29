-- StarlingCodea

--[[
StarlingCodea provides a way to work very similar to flash application.
Once initialized a stage, a juggler and a log are created, and the default draw() and touched() global function are override by local function that manage basic draw functionality and touch management.
    
Like in flash each object attached to the stage will be drawn and
each touchable object will be hitTested when a touch occurs.

Using StarlingCodeais optional, it's also possible to create a generic
DisplayObjContainer (not necessary a stage), add objects, manually
call draw() each frame and use custom TouchHandlers.
--]]

StarlingCodea = class()

StarlingCodea.current = nil

function StarlingCodea.initialize()
    StarlingCodea.current = StarlingCodea()
end

--Shows stats as overlay. Stats includes:
--fps
--avg,min and max fps in a period of 60 seconds
--(optional) memstats, showing the value obtained calling
--    collectgarbage("count")
function StarlingCodea:showStats(x,y,memstats)
    self.stats = Stats(x,y,memstats)
end

function StarlingCodea:init()
    self.stage = Stage()
    self.stage:setName("StarlingStage")
    
    self.juggler = Juggler()
    self.log = Log()
    
    self.touchIds = {}
    self.ownedTouches = {}
    
    --substitute the draw function
    local __draw = draw
    draw = function()
        self.juggler:advanceTime(DeltaTime)
        __draw()
        self.stage:draw()
        if self.stats then
            self.stats:draw()
        end
    end

    local __touched = touched
    touched = function(touch)
        local target = nil
        if self.ownedTouches[touch.id] then
            target = self.ownedTouches[touch.id]
        else
            target = self.stage:hitTest(touch.x,touch.y,nil,true)
        end
        local prevTarget = self.touchIds[touch.id]
        
        if prevTarget and prevTarget ~= target then
            prevTarget:dispatchEvent(TouchEvent(touch,target))
        end
        if target then
            target:dispatchEvent(TouchEvent(touch,target))
            if touch.state == ENDED then
                if self.touchIds[touch.id] then 
                    self.touchIds[touch.id] = nil
                end
                if self.ownedTouches[touch.id] then 
                    self.ownedTouches[touch.id] = nil
                end
            else
                self.touchIds[touch.id] = target
            end
        else
            self.touchIds[touch.id] = nil
            if __touched then
                __touched(touch)
            end
        end
    end
end

--Any object can register itself as unique listener for a specific 
--touch (id) event. That's used to manage drag logic
function StarlingCodea:startDrag(touch,obj)
    self.ownedTouches[touch.id] = obj
end

--An object can deregister itself as unique listener for a specific
--touch (id) event, but only if already registered
function StarlingCodea:stopDrag(touch,obj)
    if self.ownedTouches[touch.id] ~= obj then
        error("displayObj is not set as owner for this touch")
    end
    self.ownedTouches[touch.id] = nil
end
