-- MovieClip

--[[
A MovieClip is a simple way to display an animation depicted by a list 
of textures. Pass the frames of the movie in a vector of textures to 
the constructor. The movie clip will have the width and height of the 
first frame. If you group your frames with the help of a texture atlas
(which is recommended), use the "getTextures" method of the atlas to 
receive the textures in the correct (alphabetic) order.

It's possible to specify the desired framerate via the constructor. 
   
The methods "play" and "pause" control playback of the movie.
The "play" method accept a startFrame value. by default the 
animation start at frame 1

By default an animation is played once. It's possible to set a 
repeatCount value to increase the number of repetition. 
A negative repeatCount means infinite loops.

An Event of type Event.MovieCompleted is raised when the movie 
finished playback. If the movie is looping, the event is dispatched 
at the end of the loop.

The frame list can be inverted calling the "invertFrames" method
    
--todo: 
add sound management per frame
--]]

MovieClip = class(Image, IAnimatable)

function MovieClip:init(textures,fps,pivotMode)
    --assert(textures)
    Image.init(self,textures[1],pivotMode)
    self.fps = fps or 12
    self.animTime = 1 / fps
    self.textures = textures
    self.numFrames = #textures
    self.currentFrame = 1
    self._pause = false
    self.playing = false
    self.elapsedTime = 0
    self._repeatCount = 1
    self.eventCompleted = Event(Event.COMPLETED)
end

function MovieClip:clone(bClonePivot)
    if not bClonePivot then
        return MovieClip(self.textures,self.fps)
    else
        local obj = MovieClip(self.textures,self.fps,self._pivotMode)
        if self._pivotMode == PivotMode.CUSTOM then
            obj:setPivot(self:getPivot())
        end
        return obj
    end
end

function MovieClip:getNumFrames()
    return self.numFrames
end

function MovieClip:getCurrentFrame()
    return self.currentFrame
end

function MovieClip:play(startframe)
    if(startframe and startframe > 0 and 
            startframe <= self.numFrames) then
        self.currentFrame = startframe
    else
        self.currentFrame = 1
    end
    self._pause = false
    self.playing = true
    self.elapsedTime = 0
    self.repeatCount = self._repeatCount
    self:setTexture(self.textures[self.currentFrame])
end

function MovieClip:invertFrames()
    if not self.playing then
        self.textures = table.invert(self.textures)
    end
end

function MovieClip:setRepeatCount(repeatCount)
    assert(repeatCount ~= 0,"repeatCount cannot be 0")
    self._repeatCount = repeatCount
    self.repeatCount = repeatCount
end

function MovieClip:getRepeatCount()
    return self._repeatCount
end

function MovieClip:pause()
    self._pause = not self._pause
end

function MovieClip:stop()
    self._pause = false
    self.playing = false   
end

function MovieClip:advanceTime(deltaTime)
    if self.playing and not self._pause then
        self.elapsedTime = self.elapsedTime + deltaTime
        if self.elapsedTime > self.animTime then
            self.currentFrame = (self.currentFrame % 
                self.numFrames) + 1
                if self.currentFrame == 1 and self.repeatCount>0 then
                    self.repeatCount = self.repeatCount - 1
               
                    if self.repeatCount == 0 then
                        self:stop()
                        self:dispatchEvent(self.eventCompleted)
                    else
                        self:setTexture(
                            self.textures[self.currentFrame])
                    end
                else
                    self:setTexture(self.textures[self.currentFrame])
                end
            self.elapsedTime = 0
        end
    end
end
