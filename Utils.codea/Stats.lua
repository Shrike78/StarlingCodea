-- Stats

Stats = class()

function Stats:init(x, y, memstats)
    -- you can accept and set parameters here
    self.x = x or WIDTH/2
    self.y = y or HEIGHT - 20
    self.memstats = memstats or false
    self:Reset()
    self.fontSize = 22
end

function Stats:Reset()
    self.numUpdate = 1
    self.av_fps = 0
    self.minfps = math.huge
    self.maxfps = -math.huge
    self.refreshStats = 60
    self.refreshStatsCounter = 0
end

function Stats:draw()
    local fps = 1 / DeltaTime
    self.av_fps = math.floor((self.av_fps * (self.numUpdate-1) + 
        fps) / self.numUpdate)
        
    self.numUpdate = self.numUpdate + 1
    
    self.minfps = math.min(self.minfps,fps)
    self.maxfps = math.max(self.maxfps,fps)
    
    local str
    if self.memstats then
        str = string.format("Fps %d - %d, %d / %d - %f", fps, 
            self.av_fps, self.minfps, self.maxfps,
            collectgarbage("count"))
    else
        str = string.format("Fps %d - %d, %d / %d", fps, 
            self.av_fps, self.minfps, self.maxfps)
    end
    
    font("MyriadPro-Bold")
    fontSize(self.fontSize)
    fill(255, 255, 255, 255)
    
    text(str,self.x,self.y)
    
    self.refreshStatsCounter = self.refreshStatsCounter + 1
    if self.refreshStatsCounter >= self.refreshStats then
        self:Reset()
    end
    
end
