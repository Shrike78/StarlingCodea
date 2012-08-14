--[[
StarlingCodea

StarlingCodea starts as a  porting of the AS3 Starling Framework 
developed by Gamua OG (http://gamua.com/starling/). Starling is
an attempt to recreate over stage3D a displaylist very similar to the 
classic flash "2d" displaylist. In the same way StarlingCodea tries
to offer something very similar to the flash displaylist, wrapping
codea structures like meshes, images ecc.

StarlingCodea shares the class hieararchy, the main logic and the
overall architecture with the original Starling framework, but a lot
of things are very different, some things are simplified, others are
improved or extended. Some others are just missing.

Event management for example has been significantly simplified: there
is no "bubble" logic and a lot of standard flash/starling events are
not handled (like ADDED, REMOVED, ADDED_TO_STAGE, REMOVED_FROM_STAGE,
ENTER_FRAME).

The tween support has been improved and extended to the point to became 
a separate library that extends StarlingCodea.

Even if the displayList is very similar, the draw list is very 
different. Quads and derived objs are mapped on meshes and, due to 
optimization purposes, there's no guarantees about the final draw 
order of the objects. 

For this reason all the DisplayObjContainer methods to manage children
as an indexed list (like SwapChildren, addChildAt, ecc.) works only 
with generic displayObjs and displayObjContainers.

Fonts and text are supported by the TextField class, based upon codea 
truetype fonts. Future release should provide also support for bitmap
fonts.

Another great difference is that is not necessary to add everything to 
a stage. Each DisplayObjContainer can be drawn by itself. It's anyway
always possibile to use StarlingCodea in a more classic way, using
a stage, having a default touch event managements ecc.

--]]