## Paint Code Animation

PaintCode variables should make animation of views easy.  However, animation within `drawRect` is tough.

Here is an approach that I'm exploring.

* Create a helper class for animation called `AnimationHelper`.  It creates runs the animation from CADisplayLink timer.  

* The animation used here is SmoothStep taken from http://sol.gfxile.net/interpolation/#s4.  It should be easy to add in other timing functions via an enum.



