-- string utilities functions extension

function string.removePrefix(s, prefix)
    local i,j = string.find(s, prefix)
    --assert(i==1)
    return string.sub(s,j+1,string.len(s))
end

function string.removeSuffix(s, suffix)
    local j = string.find(s, suffix)
    return string.sub(s,1,j-1)
end

function string.split(s,re)
    local i1 = 1
    local ls = {}
    local append = table.insert
    -- if no separator is provided, it uses spaces and return an array
    -- with all the words of "s"
    if not re then 
        re = '%s+' 
    end
    if re == '' then return {s} end
        while true do
            local i2,i3 = s:find(re,i1)
            if not i2 then
                local last = s:sub(i1)
                if last ~= '' then append(ls,last) end
                if #ls == 1 and ls[1] == '' then
                    return {}
                else
                    return ls
            end
        end
        append(ls,s:sub(i1,i2-1))
        i1 = i3+1
    end
end