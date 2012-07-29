-- Event

Event = class()

--Event managed by basic StarlingCodea Projects
Event.REMOVE_FROM_JUGGLER   = "__RemoveFromJuggler__"
Event.COMPLETED             = "__Completed__"
Event.TOUCH                 = "__Touch__"
Event.TRIGGERED             = "__Triggered__"

function Event:init(type,msg)
    self.type = type
    self.sender = nil
    self.msg = msg
end

TouchEvent = class(Event)

function TouchEvent:init(touch,target)
    Event.init(self,Event.TOUCH)
    self.touch = touch
    self.target = target
end