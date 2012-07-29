-- Debugea

function __traceback()
    local result = ""
    local level = 3
    local indent = ""
    while true do
        local info = debug.getinfo(level, "nSl")
        if not info then break end
        if info.what == "C" then   -- is a C function?
            result = string.format("%s\n%d C function", result, level-2)
        else   -- a Lua function
            result = string.format("%s\n%d %s() : <line:%d>",result, level-2, info.name or "???", info.currentline)
        end
        level = level + 1
        indent = indent .. "  "
    end
    return result
end

function __errorHandler(e)    
    __db = e .. "\n" .. __traceback() .. "\n\n" .. "local variables:\n"
   
    local a = 1
    while true do
        local name, value = debug.getlocal(2, a)
        if not name then break end
        if name ~= "(*temporary)" then         
            __db = string.format("%s\n%s = %s", __db, name, value)
        end
        a = a + 1
    end 
end

function __keyboard(key)
    if true then
        if key == "\n" then
            pcall(loadstring(buffer))
            buffer = ""
        elseif key == BACKSPACE then
            if string.len(buffer) > 0 then
                buffer = string.sub(buffer, 1, string.len(buffer)-1)    
            end    
        else
            buffer = buffer .. key
        end
    end
end

function res()
    __paused = false  
    __db = ""  
end

function debugea()
    iparameter("showConsole",0,1)
    __draw = draw
    __db = ""
    watch("__db")
    __paused = false
    __sc = false
    buffer = ""
    draw = function()
        if __paused == false then
            local status, err = xpcall(__draw, __errorHandler)
            if status == false then
                __paused = true             
                showConsole = 1
            end
        else
            background(0, 0, 0, 255)
        end
        if showConsole == 1 and __sc == false then
            __sc = true
            __oldKB = keyboard
            keyboard = __keyboard
            showKeyboard()
        elseif showConsole == 0 and __sc == true then
            __sc = false
            hideKeyboard()
            keyboard = __oldKB
        end
        if __sc then
            --background(0, 0, 0, 255)
            font("Inconsolata")
            fontSize(22)
            textAlign(LEFT)
            textMode(CORNER)
            --textWrapWidth(WIDTH)
            fill(255, 255, 255, 255)
            text(" " .. buffer, 5, HEIGHT-30)
        end
    end
end
