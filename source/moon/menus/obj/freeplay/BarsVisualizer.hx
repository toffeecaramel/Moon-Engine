package moon.menus.obj.freeplay;

import openfl.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.vis.dsp.SpectralAnalyzer;
import lime.media.AudioSource;

class BarsVisualizer extends FlxGroup
{
    var grpBars:FlxTypedGroup<FlxSprite>;
    var peakLines:FlxTypedGroup<FlxSprite>;
    var analyzer:SpectralAnalyzer;
    var debugMode:Bool = false;

    public function new(audioSource:AudioSource, barCount:Int = 16)
    {
        super();

        analyzer = new SpectralAnalyzer(audioSource, barCount + 1, 0.1, 10);

        grpBars = new FlxTypedGroup<FlxSprite>();
		add(grpBars);
        peakLines = new FlxTypedGroup<FlxSprite>();
        add(peakLines);

		for (i in 0...barCount)
		{
			var spr = new FlxSprite((i / barCount) * FlxG.width, 0).makeGraphic(Std.int((1 / barCount) * FlxG.width) - 4, FlxG.height, 0xffffffff);
            spr.origin.set(0, FlxG.height);
            spr.blend = ADD;
            spr.alpha = 0.6;
			grpBars.add(spr);
            //spr = new FlxSprite((i / barCount) * FlxG.width, 0).makeGraphic(Std.int((1 / barCount) * FlxG.width) - 4, 1, 0xaaffffff);
            //peakLines.add(spr);
		}
    }

    @:generic
    static inline function min<T:Float>(x:T, y:T):T
        return x > y ? y : x;

    override function draw()
    {
        var levels = analyzer.getLevels();

        for (i in 0...min(grpBars.members.length, levels.length))
            grpBars.members[i].scale.y = flixel.math.FlxMath.lerp(grpBars.members[i].scale.y, levels[i].value, FlxG.elapsed * 16);
        super.draw();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}