package moon.game;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flxanimate.FlxAnimate;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.text.FlxText;
import moon.backend.gameplay.*;
import flixel.math.FlxPoint;

class ResultsState extends FlxState
{
    public var stats:PlayerStats;

    // The order for each text
    var textOrder:Array<String> = ['totalNotes', 'maxCombo', 'sick', 'good', 'bad', 'shit', 'miss'];
    // Position for each text, representing the orders from the array above ^^
    var posOrder:Array<FlxPoint> = [
        FlxPoint.get(372, 130), FlxPoint.get(372, 198),
        FlxPoint.get(200, 255), FlxPoint.get(200, 312),
        FlxPoint.get(200, 368), FlxPoint.get(200, 426),
        FlxPoint.get(230, 478)
    ];

    public function new(stats:PlayerStats)
    {
        super();
        this.stats = stats;
        createObjects();
    }

    var accTemp(default, set):Int = 0;
    var rank:String = '';
    public function createObjects()
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

        rank = Timings.getRank(stats.accuracy);

        new FlxTimer().start(0.4, (_) ->
        {
            results.alpha = 1;
            results.anim.play('hi', true);
            results.screenCenter(X);

            soundBooth.alpha = 1;
            soundBooth.screenCenter();
            soundBooth.x += 380; // urgh, offsets amirite?
            soundBooth.y += 123;
            soundBooth.anim.play('drop');

            new FlxTimer().start(0.4, (_) ->
            {
                judges.anim.play('show');
                judges.y += 120;
                judges.x += 25;
                judges.alpha = 1;

                for (i in 0...textOrder.length)
                {
                    new FlxTimer().start(0.6 + (0.14 * i), (_) -> {
                        final point = posOrder[i];
                        final text = textOrder[i];

                        var t = new FlxText(point.x, point.y);
                        t.setFormat(Paths.font('letterstuff/Tardling-Regular.otf'), 60, (i > 1) ? Timings.getParameters(text)[4] : FlxColor.WHITE);
                        t.text = (i == 0) ? '${stats.totalNotes}' : (i == 1) ? '${stats.highestCombo}' : '${stats.judgementsCounter.get(text)}';
                        t.textField.antiAliasType = ADVANCED;
                        t.textField.sharpness = 400;
                        add(t);
                    });
                }

                var clear = new FlxText(FlxG.width - 128);
                clear.setFormat(Paths.font('phantomuff/difficulty.ttf'), 128, FlxColor.WHITE);
                clear.screenCenter(Y);
                add(clear);

                new FlxTimer().start(0.8, (_) -> {
                    FlxTween.tween(this, {accTemp: Std.int(stats.accuracy)}, 1.8, {ease: FlxEase.quadOut, onUpdate: (_) -> {
                        clear.text = '$accTemp%';
                        clear.x = FlxG.width - clear.width - 128;
                    },
                    onComplete: (_)->{
                        clear.text = '${Std.int(stats.accuracy)}%';
                        clear.x = FlxG.width - clear.width - 128;

                        FlxTween.color(clear, 1, Timings.getRankColor(rank), FlxColor.WHITE);
                        Paths.playSFX('results/reveal$rank');

                        if(rank != 'LOSS')
                        {
                            clear.scale.set(1.3, 1.3);
                            FlxTween.tween(clear.scale, {x: 1, y: 1}, 1.3, {ease: FlxEase.elasticOut});
                            FlxTween.tween(clear, {x: FlxG.width + clear.width}, 0.8, {ease: FlxEase.expoIn, startDelay: 0.6});
                        }
                        else
                        {
                            FlxTween.tween(clear, {y: clear.y + 300, "scale.y": 0.6}, 2, {ease: FlxEase.bounceOut, onComplete: (_)->
                                FlxTween.tween(clear, {alpha: 0}, 0.6, {startDelay: 0.2})});
                        }
                    }});
                });
            });
        });
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    function set_accTemp(a:Int):Int
    {
        if(accTemp != a)
            Paths.playSFX('ui/scrollMenu');

        accTemp = a;

        return accTemp;
    }
}