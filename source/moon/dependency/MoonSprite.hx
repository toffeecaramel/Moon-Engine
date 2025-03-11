package moon.dependency;

import flixel.FlxSprite;

/**
 * A Sprite class with more compatibility over animated sprites.
 * With functions for centering offsets, adding offsets for animations, etc.
 */
class MoonSprite extends FlxSprite
{
	/**
	 * A map containing all the offsets for each animation in the sprite.
	 */
	public var animOffsets:Map<String, Array<Dynamic>>;

	/**
	 * Used for setting up if the sprite will center
	 * its offsets for the current animation.
	 */
	public var centerAnimations:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		animation.play(animName, force, reversed, frame);

		final daOffset = animOffsets.get(animName);
		if (animOffsets.exists(animName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if (centerAnimations)
		{
			centerOffsets();
        	centerOrigin();
		}
	}

	/**
	 * Adds an offset to a animation. (IMPORTANT NOTE: For offsets to apply, use `playAnim()` instead of `animation.play()`.)
	 * @param name The animation's name.
	 * @param x    The X offset.
	 * @param y    The Y offset.
	 */
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];
}