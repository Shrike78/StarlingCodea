-- EventDispatcher

--[[
The EventDispatcher class is the base class for all classes that 
dispatch events. This is the StarlingCodea version of the Flash 
class with the same name. Objects can communicate with each other 
through events. 

Compared the the Flash event system, StarlingCodea's event system 
was highly simplified. They are simply dispatched at the target. 
As in the conventional Flash classes, display objects inherit
from EventDispatcher and can thus dispatch events. 

It's possible to register a function or a method as event listenr 
of a specific event type for an object that derived from 
EventDispatcher:

--register a function
-function onEventFunc(event)
obj:addEventListener(Event.COMPLETED,onEventFunc)

--register a method
Listener = class()
-function Listener:onEvent(event)
    
listener = Listener()
obj:addEventListener(Event.COMPLETED,Listener.onEvent,listener)
--]]

EventDispatcher = class()

local Pending = {ADD = 0, REMOVE = 1, REMOVE_ALL = 2}

function EventDispatcher:init()
    --use 2 list with different index logic to store
    --functions event listener and methods event listener
    self.eventListenersFunc = {}
    self.eventListenersMethods = {}
    self.dispatching = false
    
    self.pendingList = {}
end

--[[
register/deregister a function or a method as listener of "type" 
event if listenerObj is nil, listenerFunc is considered as a 
normal function. if listenerObj is provided, listenerFunc is meant 
as a method of the class of listenerObj
--]]
function EventDispatcher:addEventListener(type, listenerFunc, 
        listenerObj)
        
    if self.dispatching then
        table.insert(self.pendingList,{
            action = Pending.ADD, 
            type = type, 
            listenerFunc = listenerFunc, 
            listenerObj = listenerObj
        })
        return
    end
    
    if not listenerObj then
        if not self.eventListenersFunc[type] then
            self.eventListenersFunc[type] = {}
        end
        table.insert(self.eventListenersFunc[type], listenerFunc)
    else
        if not self.eventListenersMethods[type] then
            self.eventListenersMethods[type] = {}
        end
        self.eventListenersMethods[type][listenerObj] = listenerFunc
    end
end

function EventDispatcher:removeEventListener(type, listenerFunc, 
        listenerObj)
    
    if self.dispatching then
        table.insert(self.pendingList,{
            action = Pending.REMOVE, 
            type = type, 
            listenerFunc = listenerFunc, 
            listenerObj = listenerObj
        })
        return
    end
    
    if not listenerObj then
        local obj = table.removeObj(self.eventListenersFunc[type], 
            listenerFunc)
            --assert(obj,
            --    "listenerFunc not registered to this eventDispatcher")
    else
        --assert(self.eventListenersMethods[type][listenerObj],
        --    "listenerMethod not registered to this eventDispatcher")
         self.eventListenersMethods[type][listenerObj] = nil
    end
end

--if type is provided remove all the listeners of this type event.
--if type is nil remove all the eventListeners, of all types
function EventDispatcher:removeEventListeners(type)
    if self.dispatching then
        table.insert(self.pendingList,{
            action = Pending.REMOVE_ALL, 
            type = type
        })
        return
    end
    
    if type then
        if self.eventListenersFunc[type] then
            table.clear(self.eventListenersFunc[type])
        end
        if self.eventListenersMethods[type] then
            table.clear(self.eventListenersMethods[type])
        end
    else
        for _,v in pairs(self.eventListenersFunc) do
            table.clear(v)
        end
        for _,v in pairs(self.eventListenersMethods) do
            table.clear(v)
        end
        table.clear(self.eventListenersFunc)
        table.clear(self.eventListenersMethods)
    end
end

--check if there's at least one eventListener for a specific type
function EventDispatcher:hasEventListener(type)
    if self.eventListenersFunc[type] and 
        #self.eventListeners[type]>0 then
            return true
    elseif self.eventListenersMethods[type] then
        for _,_ in self.eventListenersMethods[type] do
            return true
        end
    end
    return false
end

--[[
dispatch an event to all the registered listeners. While 
dispatching, the lists of listener could be modified by 
action of a listener callback, so to avoid problem in this 
phase add and remove operation are queued in a specific list
and then apply in the same order that were requested.
--]]
function EventDispatcher:dispatchEvent(event)
    --Set itself as sender of the event
    event.sender = self
    self.dispatching = true
    if self.eventListenersFunc[event.type] then
        for _,func in ipairs(self.eventListenersFunc[event.type]) do
            func(event)
        end
    end
    if self.eventListenersMethods[event.type] then
        for obj,func in pairs(self.eventListenersMethods[event.type]) do
            func(obj,event)
        end
    end
    self.dispatching = false
    
    if #self.pendingList > 0 then
        for _,v in ipairs(self.pendingList) do
            if v.action == Pending.ADD then
                self:addEventListener(v.type,
                    v.listenerFunc,v.listenerObj)
            elseif v.action == Pending.REMOVE then
                self:removeEventListener(v.type,
                    v.listenerFunc,v.listenerObj)
            elseif v.action == Pending.REMOVE_ALL then
                self:removeEventListeners(v.type)
            else
                error("illegal operation: " .. v.action)
            end
        end
        table.clear(self.pendingList)
    end
end

