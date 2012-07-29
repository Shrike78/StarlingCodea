--[[
StarlingCodea

StarlingCodea starts as a  porting of the AS3 Starling Framework 
developed by Gamua OG (http://gamua.com/starling/). Starling is
an attempt to recreate over stage3D a displaylist very similar to the 
classic flash "2d" displaylist. In the same way StarlingCodea tries
to offer something very similar to the flash displaylist, wrapping
codea structures like meshes, images ecc.

StarlingCodea shares the class hieararchy, the main logic and the overall architecture with the original Starling framework, but a lot
of things are very different, some things are simplified, others are
improved or extended. Some others are just missing.

Event management for example has been significantly simplified: there
is no "bubble" logic and a lot of standard flash/starling events are
not handled (like ADDED, REMOVED, ADDED_TO_STAGE, REMOVED_FROM_STAGE,
ENTER_FRAME).

Even if the displayList is very similar, the draw list is very 
different. For optimization purpose quads and derived objs are mapped
on meshes and there's no guarantees about the final draw order of the
objects. 

At now it's also not possible to do anything more than add or remove 
children from a DisplayObjContainer, no swap, addAt, removeByName or 
similar things. In a (hope short) future those facilities should be 
added but only for generic displayObjs and displayObjContainers 
(due to previous consideration)

The tween support has been improved and extended to the point to became 
a separate library that extends StarlingCodea

Another great difference is that is not necessary to add everything to 
a stage. Each DisplayObjContainer can be drawn by itself. It's anyway
always possibile to use StarlingCodea in a more classic way, using
a stage, having a default touch event managements ecc.

At this very moment fonts and texts are not supported by the lib, even
if it's absolutely easy to create a generic text displayobj based on 
codea text support. Future release should provide a better integration 
of ttf and the support for bitmap fonts and angel code bmp font 
descriptor
--]]