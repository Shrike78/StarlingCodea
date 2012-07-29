-- callbacks utilities

Callbacks = {}

--allows to call a spcific callback with one or more arguments.
--the current implementation allows til 4 params
function Callbacks.callFunction(callback,args)
    if not args or #args == 0 then
        callback()
    else
        local n = #args
        if n == 1 then
            callback(args[1])
        elseif n == 2 then
            callback(args[1],args[2])
        elseif n == 3 then
            callback(args[1],args[2],args[3])
        elseif n == 4 then
            callback(args[1],args[2],args[3],args[4])
        else
            error("callback with "..n.." parameters are not supported")
        end
    end
    return
end