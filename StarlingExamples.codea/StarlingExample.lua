-- StarlingExample

supportedOrientations(LANDSCAPE_LEFT)

local stage
local juggler
local random = math.random
local spriteLayer
local movieClipLayer

--debug purpose: set true to test sandboxed behaviour in a 
--unsandboxed environment
--IO.__simulateSandbox = true

--Set a dropbox subfolder as working dir for filesystem
IO.setWorkingDir(IO.DROPBOX,"StarlingExamples")

function setup()

    --Starling initialization has to be called before anything else
    StarlingCodea.initialize()
    --showStats add an overlay that shows:
    --current fps
    --avg, min and max value in a period of 60 seconds
    --the total memory in use by lua (->collectgarbage("count"))
    StarlingCodea:showStats(WIDTH/2,HEIGHT - 20,true)
    
    stage = StarlingCodea.current.stage
    --if not set, the default color is (0,0,0,255)
    stage:setBgColor(color(10,10,10))
    --the juggler is the animator of all the animated objs, like
    --movieclips, tweens or other jugglers too.
    juggler = StarlingCodea.current.juggler

    --Create a quad of size 100,100 with a pivot set in the center.
    --Quads and derived classes (images and movieclip) support 
    --PivotMode, that defaults to CENTER.
    local q = Quad(100,100,PivotMode.CENTER)
    --A color and alpha gradient is defined.
    q:setVertexColor(1,color(255,0,0))
    q:setVertexColor(2,color(255,0,0))
    q:setVertexColor(3,color(0,255,0))
    q:setVertexColor(4,color(0,255,0))
    q:setAlpha(128)
    q:setVertexAlpha(1,0)
    q:setVertexAlpha(3,255)
    --the quad is positioned in the center of the screen
    q:setPos(WIDTH/2,HEIGHT/2)
    --Function onQuadTouched is set as eventHandler for touch 
    --event of this quad
    q:addEventListener(Event.TOUCH,onQuadTouched)
    stage:addChild(q)
    
    
    --load planetCuteAtlas and pauseButtonAtlas starting from 
    --a descriptor generated by TexturePacker (3rd part tool for
    --atlas management)
    --If codea filesystem is sandboxed it uses as descriptors 
    --the moai format lua generated files. 
    --If it's unsandboxed it loads the sparrow format (same as 
    --starling) xml generated file
    local planetCuteAtlas
    local pauseAtlas
    
    if IO.isSandboxed() then
        planetCuteAtlas = TexturePacker.parseMoaiFormat(
            PlanetCuteAtlasDescriptor)
            
        pauseAtlas = TexturePacker.parseMoaiFormat(
            PauseAtlasDescriptor)
    else
        local planetCuteXml = Assets.getXml("PlanetCute.xml")
        planetCuteAtlas = TexturePacker.parseSparrowFormat(
            planetCuteXml)
            
        local pauseXml = Assets.getXml("button_pause.xml")
        pauseAtlas = TexturePacker.parseSparrowFormat(pauseXml)
    end
    
    --retrieve all the texture, ordered by name, and generated an
    --Image for each texture, then random placed, scaled and rotated.
    --Images are then added to a layer called spriteLayer
    local textures = planetCuteAtlas:getTextures()
    
    spriteLayer = DisplayObjContainer()
    --it's possible to set a name to each displayObj.
    --The main purpose is for debug
    spriteLayer:setName("spriteLayer")
    
    for _,texture in ipairs(textures) do
        local img = Image(texture)
        img:setPos(random(WIDTH),random(HEIGHT))
        local s = random(5,10)/10
        img:setScale(s,s)
        img:setRotation(random(0,math.pi *2))
        spriteLayer:addChild(img)
    end
    --spriteLayer pivot is set in the middle of the layer, so from
    --now on transformation on this layer will be referred to this
    --point. The pivot is then placed in the middle of the screen.
    --the desired effect is to center the layer in the middle of 
    --the screen
    spriteLayer:setPivot(spriteLayer:getWidth()/2,
        spriteLayer:getHeight()/2)
    spriteLayer:setPos(WIDTH/2,HEIGHT/2)
    
    --the layer is set as not touchable, so starling will never 
    --provide TouchEvents for this layer and its children
    spriteLayer:setTouchable(false)
    
    stage:addChild(spriteLayer)
    
    --using tween library 3 different composed tween are generated
    local tweenTime1 = 4
    local tweenTime2 = 2
    local tweenTime3 = 10
    
    
    --Define an infinite loop of an ease.linear animation of the 
    --rotation value of spriteLayer. A complete rotation of the layer 
    --will be done in tweenTime1 seconds:
    
    --1. declare the type (ease with transition linear), the target
    --(spriteLayer) and the duration (tweenTime1)
    local ease = Tween.ease(spriteLayer,tweenTime1, Transition.LINEAR)
    
    --2. define the properites of the target that will be animated
    --It's possile to animate multiple properties with a single tween.
    --It's also possible to animate properties expressed as variables 
    --with the animate method, or properties expressed by a couple of 
    --setter/getter through the animateEx method.
    --rotation values are expressed in radians and are in the range 
    --[-180 deg, +180 deg]
    ease:animateEx(spriteLayer.setRotation, spriteLayer.getRotation,
        math.pi*2)
    --3. define a tween loop that has a tween as target, and a 
    --repetition count to express the number of iteration.
    --Negative repetition count means infinite loop repetitiom
    local loop = Tween.loop(ease,-1)
    --4. add the loop tween to the juggler
    juggler:add(loop)
        
    --infinite loop of a sequence of two ease.in_out_cubic animation
    --of the scale value of the spriteLayer. The ease start always from
    --current value (defined through getter method) so:
    --first iteration:    scale = (1,1)     -> (2,2) -> (0.1,0.1)
    --other iterations:   scale = (0.1,0.1) -> (2,2) -> (0.1,0.1)
    
    --As showns it's possible to define tweens with a single expression:
    juggler:add(
        Tween.loop(
            Tween.sequence(
                Tween.ease(spriteLayer,tweenTime2,
                    Transition.IN_OUT_CUBIC):animateEx(
                        spriteLayer.setScale_v2,
                        spriteLayer.getScale_v2,
                        vec2(2,2)),
        
                Tween.ease(spriteLayer,tweenTime2,
                    Transition.IN_OUT_CUBIC):animateEx(
                        spriteLayer.setScale_v2,
                        spriteLayer.getScale_v2,
                        vec2(0.1,0.1))
            ),
            -1
        )
    )
    
    --infinite animation of the position of the layer, following a
    --bezier curve defined by a set of control points.
    juggler:add(
        Tween.loop(
            Tween.bezier(spriteLayer,tweenTime3):animateEx(
                spriteLayer.setPos_v2,
                vec2(0,0),
                vec2(0,HEIGHT),
                vec2(WIDTH,HEIGHT),
                vec2(WIDTH,0),
                vec2(0,0)
            ),
            -1
        )
    )
    
    --create two movieclip, one that shows all the texture of type
    --"characters" and one that shows all the texture of type "chest"
    movieClipLayer = DisplayObjContainer()
    movieClipLayer:setName("movieClipLayer")
    stage:addChild(movieClipLayer)
    
    --this time the layer pivot is not set as relative point but 
    --absolute. The desired effect is to have a layer of arbitrary 
    --boundary rotating around the center of the screen 
    movieClipLayer:setPivot(WIDTH/2,HEIGHT/2)
    movieClipLayer:setPos(WIDTH/2,HEIGHT/2)
    
    --define a movieclip (animation) that run at 5 fps and that play,
    --ordered by name, all the subtextures of planetCuteAtlas that 
    --have "Character" as name prefix
    character = MovieClip(planetCuteAtlas:getTextures("Character"),5)
    character:setPos(100,100)
    --infinite loop of the animation
    character:setRepeatCount(-1)
    --play the animation starting from frame 1 (default)
    character:play(2)
    movieClipLayer:addChild(character)
    juggler:add(character)
    character:addEventListener(Event.TOUCH,onCharacterTouched)
    
    --define a movieclip (animation) that run at 5 fps and that play,
    --ordered by name, all the subtextures of planetCuteAtlas that 
    --have "Chest" as name prefix
    chest = MovieClip(planetCuteAtlas:getTextures("Chest"),2)
    --play frames in reverse order
    chest:invertFrames()
    chest:setPos(400,100)
    chest:setRepeatCount(-1)
    --play the animation starting from frame 2  
    chest:play(2)
    movieClipLayer:addChild(chest)
    juggler:add(chest)
    chest:addEventListener(Event.TOUCH,onChestTouched)
    
    --define a button that use button_pause_up as texture for
    --the up state and button_pause_down afor the pressed state
    local buttonPause = Button(
        pauseAtlas:getTexture("button_pause_up"),
        pauseAtlas:getTexture("button_pause_down")
    )
    
    --whenever buttonPause is pressed (on touch ENDED),
    --the listener function is called.
    --The function is defined in place and force
    --the main juggler to be paused/unpaused
    buttonPause:addEventListener(Event.TRIGGERED,function(e)
            juggler:setPause(not juggler:isPaused())
        end
    )
    
    buttonPause:setName("buttonPause")
    buttonPause:setPos(WIDTH - 60,HEIGHT - 40)
    stage:addChild(buttonPause)
    
    --show debug infos of current stage. the true parameter
    --force the recursion on all the children DisplayObjContainer
    print(stage:dbgInfo(true))
    
    --add parameters to control layer visibility
    iparameter("spriteLayer_visible",0,1,1)
    iparameter("movieClipLayer_visible",0,1,1)
    --used to activate moviclipLayer rotation
    iparameter("rotate_movieClipLayer",0,1,0)
end

--Default draw function. If Starling is initialized
--this is called after "bqckground" and before stage:draw() and
--is used as update function for any object attached to the stage
--NB: if the main juggler is paused this code is executed anyway!
function draw()
    spriteLayer:setVisible(spriteLayer_visible==1)
    movieClipLayer:setVisible(movieClipLayer_visible==1)
    if rotate_movieClipLayer == 1 then
        movieClipLayer:setRotation(movieClipLayer:getRotation() +
            math.pi/720)
    end
end

--default touched function. called when no object handle the 
--current touch
function touched(touch)
end

--when the quad receives a touch event (of any state), it's
--rotated of 45 degrees (rotation in starling is always expressed
--in radians, so math.pi/4)
function onQuadTouched(e)
    e.sender:setRotation(e.sender:getRotation() + math.pi/4)
end

--whenever character movieclip is touched it's randomly repositioned
function onCharacterTouched(e)
    if e.touch.state == BEGAN then
        e.sender:setPos(random(WIDTH),random(HEIGHT))
    end
end

--if chest movieclip os touched the drag behaviour is activated,
--so it's possible to drag it around the screen
function onChestTouched(e)
    local touch = e.touch
    local sender = e.sender
    local target = e.target
    
    if sender == target then
        StarlingCodea.current:startDrag(touch,target)
    end
    
    if touch.state == MOVING then
        --new position is expressed in parent coordinates
        local x,y = sender.parent:globalToLocal(touch.x,touch.y)
        sender:setPos(x,y)
    end
end