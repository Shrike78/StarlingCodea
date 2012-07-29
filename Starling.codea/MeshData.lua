-- MeshData

MeshData = class()

function MeshData:init(mesh,idx)
    self.mesh = mesh
    self.idx = idx
end

--[[
setVertexColor(vertex,c)
setVertexColor(vertex,r,g,b)
setVertexColor(vertex,r,g,b,a)
--]]
function MeshData:setVertexColor(vertex,r,g,b,a)
    local idx = (self.idx - 1) * 6 + 1
    if vertex == 1 then
        self.mesh:color(idx,r,g,b,a)
        self.mesh:color(idx+3,r,g,b,a)
    elseif vertex == 2 then
        self.mesh:color(idx+1,r,g,b,a)
    elseif vertex == 3 then
        self.mesh:color(idx+2,r,g,b,a)
        self.mesh:color(idx+4,r,g,b,a)
    elseif vertex == 4 then
        self.mesh:color(idx+5,r,g,b,a)
    else
        error("vertex "..vertex.." is not valid")
    end  
end
