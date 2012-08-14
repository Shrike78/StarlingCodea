-- Color
local floor = math.floor

Color = {}

function Color.blend(c1, c2, a)
    return color(c1.r * a + c2.r * (1-a),
                 c1.g * a + c2.g * (1-a),
                 c1.b * a + c2.b * (1-a),
                 c1.a
                )
end

function Color.hsv2rgb(h, s, v)
    -- h, s, v is allowed having values between [0 ... 1].

    h = 6 * h
    local i = floor(h - 0.000001)
    local f = h - i
    local m = v*(1-s)
    local n = v*(1-s*f)
    local k = v*(1-s*(1-f))
    local r,g,b
    
    if i<=0 then
        r = v; g = k; b = m
    elseif i==1 then
        r = n; g = v; b = m
    elseif i==2 then
        r = m; g = v; b = k
    elseif i==3 then
        r = m; g = n; b = v
    elseif i==4 then
        r = k; g = m; b = v
    elseif i==5 then
        r = v; g = m; b = n
    end
    return floor(r*255), floor(g*255), floor(b*255)
end
