-- XmlNode

XmlNode = class(name,attributes,value,children,parent)

function XmlNode:init(name,attributes,value,children,parent)
    self.name = name
    self.value = value
    self.parent = parent
    self.attributes = attributes or {}
    self.childNodes = children or {}
end

function XmlNode.fromLuaXml(xml,parent)    
    local node = XmlNode(xml.name,xml.attributes,
        xml.value,nil,parent)  
    if xml.childNodes then
        for _,child in pairs(xml.childNodes) do
            childNode = XmlNode.fromLuaXml(child,node)
            node:addChild(childNode)
        end 
    end
    return node
end

function XmlNode.fromString(xml)
    local luaXml = XmlParser:ParseXmlText(xml)
    local xmlNode = XmlNode.fromLuaXml(luaXml)
    return xmlNode
end

function XmlNode:addChild(child)
    table.insert(self.childNodes,child)
end

function XmlNode:getAttribute(name)
    if self.attributes and self.attributes[name] then
        return self.attributes[name]
    end
    return nil
end

--return a number attribute already converted as number
function XmlNode:getAttributeN(name)
    return tonumber(self:getAttribute(name))
end

function XmlNode:getAttributeName(idx)
    local i=1
    for k,_ in pairs(self.attributes) do
        if i == idx then
            return k
        end
        i = i + 1
    end
end

function XmlNode:getNumAttributes()
    local i=0
    for _,_ in pairs(self.attributes) do
        i = i + 1
    end
    return i
end

function XmlNode:getChildren(name)
    if not name then
        return self.childNodes
    else
        tmp = {}
        for _,child in pairs(self.childNodes) do
            if child.name and child.name == name then
                table.insert(tmp,child)
            end
        end
        return tmp
    end
end

function XmlNode:getParent()
    return self.parent
end

function XmlNode:dump(stringbuilder)
    stringbuilder:writeln(self.name)
    if self.value then 
        stringbuilder:writeln(self.value)
    end
    for i,v in pairs(self.attributes) do
        stringbuilder:writeln(i.." = "..v)
    end
    for _,xmlNode in pairs(self:getChildren()) do
        xmlNode:dump(stringbuilder)
    end
end

XmlNode.__tostring = function(o) 
    sb = StringBuilder()
    o:dump(sb)
    return sb:toString(true)
end
    
