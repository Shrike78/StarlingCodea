-- Dependencies

--[[
StarlingTweens already import itself Utils and Starling.
Import works only in a unsandboxed codea environment thanks to 
Rui Viana luaSandbox.lua modified version.

If working in a sandboxed codea version, all the sub libs
(ExternalLibs,Utils,Starling,StarlingTween) has to be collapsed
in one single lib. Then instead of "import", rely on codea 
dependency manager
--]]
--import("ExternalLibs")
--import("Utils")
--import("Starling")
import("StarlingTween")