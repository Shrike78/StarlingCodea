-- TextField

--[[
A TextField displays text using standard true type fonts. It's possible 
to set properties like the font name and size, a color, the alignment, 
etc. 

The border property is helpful during development, because it shows
the bounds of the textfield.

TextField class uses the same PivotMode of the Quad class, so it's possible to 
set a custom pivot or setting it centered, at the bottom left or top left
position.

The width and height parameter are used to define the exact area of the textfield, 
and the resulting text is a texture so if the text size is greater then the 
textfield area, the text will be cut vertically. (Horizontally the wrap should
be guarantee by the textWrapWidth codea function)

Even if a TextField is a DisplayObjContainer, it doesn't allow to manually modify
childrens.
--]]

TextField = class(DisplayObjContainer)

function TextField:init(width, height, text, fontName, fontSize, 
        align, col, pivotMode)
    
    DisplayObjContainer.init(self)
    
    self.textProps = {
        width = width,
        height = height,
        text = text,
        fontName = fontName or "Helvetica",
        fontSize = fontSize or 17,
        align = align or LEFT,
        color = col or color(0,0,0),
        pivotMode = pivotMode or PivotMode.CENTER,
        showBorder = false,
        textWidth = 0,
        textHeight = 0
    }
    self:_updateTextfield(true)
end

function TextField:_updateTextfield(bUpdateTexture)
    local props = self.textProps
    
    if bUpdateTexture or not self.txtTexture then
        local img = image(props.width,props.height)
        self.emptyImg = image(props.width,props.height)
        self.txtTexture = Texture(img)
    end

    setContext(self.txtTexture:image())
    pushStyle()
    clip(0,0,props.width,props.height)
    background(0,0,0,0)
    textWrapWidth(props.width)
    font(props.fontName)
    fontSize(props.fontSize)
    fill(props.color)
    textAlign(props.align)
    textMode(CENTER)
    --store the text size as usefull information
    props.textWidth, props.textHeight = textSize(props.text)
    local x
    if props.align == LEFT then
        x = props.textWidth/2
    elseif props.align == CENTER then
        x = props.width/2
    else
        x = props.width - props.textWidth/2
    end
    text(props.text,x,props.height/2)
    if props.showBorder then
        fill(props.color.r,props.color.g,props.color.b, 50)
        strokeWidth(2)
        rectMode(CORNER)
        rect(0,0, props.width, props.height)
    end
    popStyle()
    setContext()
    
    if not self.txtImg then
        self.txtImg = Image(self.txtTexture,PivotMode.BOTTOM_LEFT)
        DisplayObjContainer.addChild(self,self.txtImg)
    else
        self.txtImg:setTexture(self.txtTexture)
    end
    
    --remove previous mesh no more used
    if bUpdateTexture then
        self:optimize()
    end
    
    if props.pivotMode == PivotMode.CENTER then
        self:setPivot(self:getWidth()/2, self:getHeight()/2)
    elseif props.pivotMode == PivotMode.TOP_LEFT then
        self:setPivot(0, self:getHeight())
    end
end

function TextField:setTextProp(name,value,newTexture)
    if self.textProps[name] ~= value then
        self.textProps[name] = value
        self:_updateTextfield(newTexture)
    end
end

function TextField:setTextFieldWidth(width)
    self:setTextProp("width",width,true)
end

function TextField:setTextFieldHeight(height)
    self:setTextProp("height",height,true)
end

function TextField:getTextFieldWidth()
    return self.textProps.width
end

function TextField:getTextFieldHeight()
    return self.textProps.height
end

function TextField:getTextSize()
    return self.textProps.textWidth, self.textProps.textHeight
end

function TextField:setText(text)
    self:setTextProp("text",text)
end

function TextField:getText()
    return self.textProps.text
end

function TextField:setFontName(fontName)
    self:setTextProp("fontName",fontName)
end

function TextField:getFontName()
    return self.textProps.fontName
end

function TextField:setFontSize(fontSize)
    self:setTextProp("fontSize",fontSize)
end

function TextField:getFontSize()
    return self.textProps.fontSize
end

function TextField:setTextAlign(align)
    self:setTextProp("align",align)
end

function TextField:getTextAlign()
    return self.textProps.align
end

function TextField:setTextColor(r,g,b)
    self:setTextProp("color",color(r,g,b))
end

function TextField:getTextColor()
    return self.color.r, self.color.g, self.color.b
end

function TextField:setPivotMode(pivotMode)
    local props = self.textProps
    if pivotMode ~= props.pivotMode then
        props.pivotMode = pivotMode
        if props.pivotMode == PivotMode.CENTER then
            self:setPivot(self:getWidth()/2, self:getHeight()/2)
        elseif props.pivotMode == PivotMode.TOP_LEFT then
            self:setPivot(0, self:getHeight())
        elseif props.pivotMode == PivotMode.BOTTOM_LEFT then
            self:setPivot(0, 0)
        end
    end
end

function TextField:getPivotMode()
    return self.props.pivotMode
end
    
function TextField:showBorder(bVisible)
    self:setTextProp("showBorder",bVisible)
end


--override children modifier methods to avoid to misuse the Textfield
function TextField:addChild(obj)
    error("it's not possible to directly manage Textfield children")
end

function TextField:removeChild(obj)
    error("it's not possible to directly manage Textfield children")
end

function TextField:addChildAt(obj,index)
    error("it's not possible to directly manage Textfield children")
end

function TextField:removeChildAt(index)
    error("it's not possible to directly manage Textfield children")
end

function TextField:getChildIndex(obj)
    error("it's not possible to directly manage Textfield children")
end

function TextField:getChildAt(index)
    error("it's not possible to directly manage Textfield children")
end

function TextField:swapChildren(obj1,obj2)
    error("it's not possible to directly manage Textfield children")
end

function TextField:swapChildrenAt(index1,index2)
    error("it's not possible to directly manage Textfield children")
end
