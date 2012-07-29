-- SpatialHashMap

local floor = math.floor
local min, max = math.min, math.max

SpatialHashMap = class()

function SpatialHashMap:init(cell_size_x,cell_size_y)
    self.cell_size_x = cell_size_x or 100
    self.cell_size_y = cell_size_y or 100
    self.cells = {}
end

function SpatialHashMap:cellCoords(x,y)
    return floor(x / self.cell_size_x), floor(y / self.cell_size_y)
end

function SpatialHashMap:cell(i,k)
    local row = self.cells[i]
    if not row then
        row = {}
        self.cells[i] = row
    end

    local cell = row[k]
    if not cell then
        --cell = setmetatable({}, {__mode = "kv"})
        cell = {}
        row[k] = cell
    end

    return cell
end

function SpatialHashMap:cellAt(x,y)
    return self:cell(self:cellCoords(x,y))
end

function SpatialHashMap:insert(obj, x1, y1, x2, y2)
    x1, y1 = self:cellCoords(x1, y1)
    x2, y2 = self:cellCoords(x2, y2)
    for i = x1,x2 do
        for k = y1,y2 do
            self:cell(i,k)[obj] = obj
        end
    end
end

function SpatialHashMap:remove(obj, x1, y1, x2,y2)
    -- no bbox given. => must check all cells
    if not (x1 and y1 and x2 and y2) then
        for _,row in pairs(self.cells) do
            for _,cell in pairs(row) do
                cell[obj] = nil
            end
        end
        return
    end

    -- else: remove only from bbox
    x1,y1 = self:cellCoords(x1,y1)
    x2,y2 = self:cellCoords(x2,y2)
    for i = x1,x2 do
        for k = y1,y2 do
            self:cell(i,k)[obj] = nil
        end
    end
end

-- update an objects position
function SpatialHashMap:update(obj, old_x1,old_y1, old_x2,old_y2, new_x1,new_y1, new_x2,new_y2)
    
    old_x1, old_y1 = self:cellCoords(old_x1, old_y1)
    old_x2, old_y2 = self:cellCoords(old_x2, old_y2)

    new_x1, new_y1 = self:cellCoords(new_x1, new_y1)
    new_x2, new_y2 = self:cellCoords(new_x2, new_y2)

    if old_x1 == new_x1 and old_y1 == new_y1 and
       old_x2 == new_x2 and old_y2 == new_y2 then
        return
    end

    for i = old_x1,old_x2 do
        for k = old_y1,old_y2 do
            self:cell(i,k)[obj] = nil
        end
    end
    for i = new_x1,new_x2 do
        for k = new_y1,new_y2 do
            self:cell(i,k)[obj] = obj
        end
    end
end

function SpatialHashMap:getObjectsAtPoint(x,y)
    x,y = self:cellCoords(x,y)
    local set = {}
    local cell = self:cell(x,y)
    for obj in pairs(cell) do
        set[obj] = obj
    end
    return set
end

function SpatialHashMap:getObjectsInArea(x1,y1,x2,y2)
    x1,y1 = self:cellCoords(x1,y1)
    x2,y2 = self:cellCoords(x2,y2)

    local set = {}
    for i = x1,x2 do
        for k = y1,y2 do
            local cell = self:cell(i,k)
            for obj in pairs(cell) do
                set[obj] = obj
            end
        end
    end
    return set
end

function SpatialHashMap:getNeighbors(obj, x1,y1, x2,y2)
    local set = self:getObjectsInArea(x1,y1, x2,y2)
    set[obj] = nil
    return set
end
