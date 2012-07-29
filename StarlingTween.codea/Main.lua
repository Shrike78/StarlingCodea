--[[
StarlingTween

Starling tween starts as porting of the Tween and DelayedCall 
implementation that can be found in the AS3 Starling Framework 
developed by Gamua OG (http://gamua.com/starling/), as parts of
the StarlingCodea project.

The support has grown til to became a separated library that depends
and extends StarlingCodea. The dependency from StarlingCodea are
only to Event/EventDispatcher class and to Juggler/IAnimatable 
animation support, so it would be easy to separate this library from
StarlingCodea if needed.

StarlingCodea implements several facilities to animate properties of
objects, where properties can be exposed variables (using the animate
method of each tween object) or a couple of setter/getter methods (
using the animateEx method of each tween object):

- ease (with a large set of ease transition function)
- delay
- bezier path
- parallel exection of more tweens
- sequential execution of more tweens
- looped execution of a tween

All the tween object can be composed together and animated through a 
juggler object taht calls the advanceTime method.

It's also possible to set three different callbacks to each tween 
object:

- onStart callback
- onUpdate callback
- onEnd callback

--]]