-- CollisionKit

--[[
imageHitTest

check pixel perfect overlap of 2 images

parameters
    i1: image 1
    p1: position (vec2) of image1
    a1: alpha treshold to consider image1 pixel transparent
    i2: image 2
    p2: position (vec2) of image2
    a2: alpha treshold to consider image2 pixel transparent
--]]
function imageHitTest(i1,p1,a1,i2,p2,a2)

    local w1 = i1.width
    local h1 = i1.height
    local w2 = i2.width
    local h2 = i2.height
    
    local r1 = Rect(p1.x,p1.y,w1,h1)
    local r2 = Rect(p2.x,p2.y,w2,h2)
    if not r1:intersects(r2) then 
        return false 
    end
    if p1.x <= p2.x then
        r1.x = p2.x - p1.x
        r2.x = 0
        r1.w = r1.w - r1.x
    else
        r1.x = 0
        r2.x = p1.x - p2.x
        r1.w = r2.w - r2.x
    end
    if p1.y <= p2.y then
        r1.y = p2.y - p1.y
        r2.y = 0
        r1.h = r1.h - r1.y
    else
        r1.y = 0
        r2.y = p1.y - p2.y
        r1.h = r2.h - r2.y
    end
    for i = 1,r1.w do
        for j = 1,r1.h do
            local r,g,b,a = i1:get(r1.x+i,r1.y+j)
            if a > a1 then
                r,g,b,a = i2:get(r2.x+i,r2.y+j)
                if a > a2 then
                    return true
                end
            end
        end
    end
    return false

end