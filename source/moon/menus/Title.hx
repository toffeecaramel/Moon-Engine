package moon.menus;

import moon.menus.obj.BarsVisualizer;
import moon.global_obj.GlobalMusic;
import flixel.math.FlxMath;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxState;
import moon.global_obj.Alphabet;

class Title extends FlxState
{
    var grid1:FlxBackdrop;
    var grid2:FlxBackdrop;
    var logo:MoonSprite;

    var circles:Array<FlxShapeCircle> = [];
    override public function create():Void
    {
        super.create();

        // bg
        var bg = new MoonSprite().makeGraphic(FlxG.width, FlxG.height, 0xff0c0c15);
        add(bg);

        var backVis = new BarsVisualizer(8);
        backVis.color = FlxColor.BLUE;
        backVis.blend = ADD;
        backVis.alpha = 0.1;
        add(backVis);
        
        var gradient = FlxGradient.createGradientFlxSprite(
            FlxG.width, FlxG.height,
            [0xff1022c1, FlxColor.TRANSPARENT, 0xffca15ac]
        );
        gradient.alpha = 0.2;
        add(gradient);
            

        // grids
        grid1 = new FlxBackdrop(null, X, 0, 0);
        grid1.loadGraphic(Paths.image('menus/title/bgGrid'));
        grid1.antialiasing = true;
        grid1.alpha = 0.2;
        grid1.screenCenter();
        grid1.y -= 40;
        add(grid1);

        grid2 = new FlxBackdrop(null, X, 0, 0);
        grid2.loadGraphic(Paths.image('menus/title/bgGrid'));
        grid2.antialiasing = grid1.antialiasing;
        grid2.alpha = grid1.alpha;
        grid2.screenCenter();
        grid2.y = grid1.y + grid1.height;
        add(grid2);

        grid1.velocity.x = 12;
        grid2.velocity.x = -12;

        // create clock circles
        for(i in 0...3)
        {
            final stuff = [10, 14, 18];
            var awa = new FlxShapeCircle(0, 0, stuff[i], { thickness: 4, color: FlxColor.WHITE }, FlxColor.TRANSPARENT);
            awa.antialiasing = true;
            add(awa);
            awa.screenCenter();
            awa.blend = ADD;
            awa.alpha = 0.5;
            awa.y += FlxG.height;

            circles.push(awa);
        }

        logo = new MoonSprite().loadGraphic(Paths.image('menus/title/logo-white'));
        logo.screenCenter();
        add(logo);

        GlobalMusic.song = 'menus/freakyMenu';
        GlobalMusic.start(true);
        
        @:privateAccess
        backVis.setAudioSource(cast FlxG.sound.music._channel.__audioSource);

        if(GlobalMusic.conductor != null)
        {
            GlobalMusic.conductor.onBeat.add((beat) -> 
            {
                trace('agwa');
                logo.scale.set(1.1, 1.1);
            });
        }
    }

    final orbitDistance:Float = 130 * 2;
    override public function update(elapsed:Float):Void
    {
        GlobalMusic.update();
        super.update(elapsed);

        logo.scale.x = logo.scale.y = FlxMath.lerp(logo.scale.x, 1, elapsed * 10);

        for(i in 0...circles.length)
        {
            // my brain got eated
            //pffflllrrtrtrgr
            final circle = circles[i];
            final angles = [
                (Math.PI * 2) * (Date.now().getSeconds() / 60) - Math.PI/2,
                (Math.PI * 2) * (Date.now().getMinutes() / 60) - Math.PI/2,
                (Math.PI * 2) * ((Date.now().getHours() % 12 * 60 + Date.now().getMinutes()) / 720) - Math.PI/2
            ];

            final x = FlxG.width / 2 + Math.cos(angles[i]) * orbitDistance;
            final y = FlxG.height / 2 + Math.sin(angles[i]) * orbitDistance;
            circle.setPosition(FlxMath.lerp(circle.x, x, elapsed), FlxMath.lerp(circle.y, y, elapsed));
        }
    }
}
