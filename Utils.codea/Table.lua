-- table utilities functions extension
        
function table.clear(t)
    for k,_ in pairs(t) do
        t[k] = nil
    end
end  

function table.copy(t)
    local u ={}
    for k,v in pairs(t) do
        u[k] = v
    end
    return setmetatable(u, getmetatable(t))
end

function table.deepcopy(t)
    if type(t) ~= 'table' then 
        return t 
    end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            res[k] = table.deepcopy(v)
        else
            res[k] = v
        end
    end
    setmetatable(res,mt)
    return res
end 

function table.removeKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function table.find(t,o)
    local c = 1
    for _,v in pairs(t) do
        if(v == o) then
            return c
        end
        c = c + 1
    end
    return 0
end

function table.removeObj(t, o)
    local i = table.find(t,o)
    if i then 
        return table.remove(t,i)
    end
    return nil
end


function table.invert(t)
    local new = {}
    for i=0, #t do
        table.insert(new, t[#t - i])
    end
    return new
end
