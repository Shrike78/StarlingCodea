-- Matrix
Matrix = {}
   
function Matrix.transformPoint(m,x,y)
    local x1 = m[1] * x + m[5] * y + m[13]
    local y1 = m[2] * x + m[6] * y + m[14]
    return x1,y1
end

function Matrix.transformVec2(m,v,res_v)
    local x1 = m[1] * v.x + m[5] * v.y + m[13]
    local y1 = m[2] * v.x + m[6] * v.y + m[14]
    if res_v then
        res_v.x = x1
        res_v.y = y1
        return res_v
    end    
    return vec2(x1,y1)
end

function Matrix.transformVec3(m,v,res_v)
    local x1 = m[1] * v.x + m[5] * v.y + m[9] * v.z + m[13]
    local y1 = m[2] * v.x + m[6] * v.y + m[10] * v.z + m[14]
    local z1 = m[3] * v.x + m[7] * v.y + m[11] * v.z + m[15]
    if res_v then
        res_v.x = x1
        res_v.y = y1
        res_v.z = z1
        return res_v
    end    
    return vec3(x1,y1,z1)
end
