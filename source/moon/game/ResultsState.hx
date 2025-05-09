package moon.game;

import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxGradient;
import flixel.FlxState;

class ResultsState extends FlxState
{
    override public function create()
    {
        super.create();
        
        var back = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECD5C, 0xFFFF9D47]);
        add(back);
        back.alpha = 0.0001;
        FlxTween.tween(back, {alpha: 1}, 0.7);

        var soundBooth = new FlxAnimate();
        soundBooth.loadAtlas(Paths.getPath("images/ingame/results/UI/soundBooth", null));
        soundBooth.anim.addBySymbol('drop', 'sound system', 24, false);
        soundBooth.alpha = 0.0001;
        add(soundBooth);

        var judges = new FlxAnimate();
        judges.loadAtlas(Paths.getPath("images/ingame/results/UI/judgesDisplay", null));
        judges.anim.addBySymbol('show', 'categories', 24, false);
        judges.alpha = 0.0001;
        add(judges);

        var bb = new MoonSprite().loadGraphic(Paths.image('ingame/results/UI/bb'));
        add(bb);

        var results = new FlxAnimate();
        results.loadAtlas(Paths.getPath("images/ingame/results/UI/resultsTxt", null));
        results.anim.addBySymbol("hi", "results", 24, false);
        results.alpha = 0.0001;
        add(results);

        //category symbol name:
        // categories or category idont remem ber

        new FlxTimer().start(0.5, (_) -> {
            results.alpha = 1;
            results.anim.play('hi', true);
            results.screenCenter(X);

            soundBooth.alpha = 1;
            soundBooth.screenCenter();
            soundBooth.x += 395; // urgh, offsets amirite?
            soundBooth.y += 123;
            soundBooth.anim.play('drop');

            new FlxTimer().start(0.75, (_) -> {
                judges.anim.play('show');
                judges.y += 120;
                judges.x += 25;
                judges.alpha = 1;
            });
        });
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}