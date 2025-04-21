package moon.menus;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.util.FlxTimer;
import moon.dependency.MoonSound.Metadata;
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
    var circles:FlxTypedSpriteGroup<FlxShapeCircle> = new FlxTypedSpriteGroup<FlxShapeCircle>();
    var objects:Array<FlxBasic> = []; // the objects that are hidden on start
    var displayTxt:FlxText;

    var conductor:Conductor;

    var randomText:Array<String> = [];

    var songMeta:Metadata;

    var onTitle:Bool = false; //For tracking when the alphabet isnt on screensies
    override public function create():Void
    {
        super.create();
        
        var backVis = new BarsVisualizer(16);
        backVis.blend = ADD;
        backVis.alpha = 0.4;
        add(backVis);
        objects.push(backVis);

        // bg
        var bg = new MoonSprite().makeGraphic(FlxG.width, FlxG.height, 0xff1e1e39);
        bg.alpha = 0.8;
        add(bg);
        objects.push(bg);
        
        var gradient = FlxGradient.createGradientFlxSprite(
            FlxG.width, FlxG.height,
            [0xff1022c1, FlxColor.TRANSPARENT, 0xffca15ac]
        );
        gradient.alpha = 0.2;
        add(gradient);
        objects.push(gradient);

        // grids
        grid1 = new FlxBackdrop(null, X, 0, 0);
        grid1.loadGraphic(Paths.image('menus/title/bgGrid'));
        grid1.antialiasing = true;
        grid1.alpha = 0.2;
        grid1.screenCenter();
        grid1.y -= 40;
        add(grid1);
        objects.push(grid1);

        grid2 = new FlxBackdrop(null, X, 0, 0);
        grid2.loadGraphic(Paths.image('menus/title/bgGrid'));
        grid2.antialiasing = grid1.antialiasing;
        grid2.alpha = grid1.alpha;
        grid2.screenCenter();
        grid2.y = grid1.y + grid1.height;
        add(grid2);
        objects.push(grid2);

        grid1.velocity.x = 12;
        grid2.velocity.x = -12;

        add(circles);
        // create clock circles
        for(i in 0...3)
        {
            final stuff = [10, 16, 24];
            var awa = new FlxShapeCircle(0, 0, stuff[i], { thickness: 4, color: FlxColor.WHITE }, FlxColor.TRANSPARENT);
            awa.antialiasing = true;
            circles.add(awa);
            awa.screenCenter();
            awa.blend = ADD;
            awa.alpha = 0.5;
            awa.y += FlxG.height;
            awa.origin.set(awa.width / 2, awa.height / 2);
        }

        logo = new MoonSprite().loadGraphic(Paths.image('menus/title/logo-white'));
        logo.screenCenter();
        add(logo);
        objects.push(logo);

        displayTxt = new FlxText(0, 0);
        displayTxt.setFormat(Paths.font('monsterrat/Montserrat-ExtraBold.ttf'), 32, FlxColor.WHITE, CENTER);
        add(displayTxt);

        //GlobalMusic.song = 'menus/freakyMenu';
        //GlobalMusic.start(true);
        GlobalMusic.start('menus/freakyMenu', true);
        songMeta = (Paths.fileExists('assets/music/menus/freakyMenu-metadata.json', TEXT)) ? Paths.JSON('menus/freakyMenu-metadata', "music") : null;

        if(songMeta != null)
        {
            conductor = new Conductor(songMeta.bpm ?? 0, songMeta.timeSignature[0] ?? 4, songMeta.timeSignature[1] ?? 4);
            FlxG.sound.music.looped = songMeta.looped;
        }
        
        @:privateAccess
        backVis.setAudioSource(cast FlxG.sound.music._channel.__audioSource);

        conductor.onBeat.add((beat) -> 
        {
            trace(beat);
            logo.scale.set(1.1, 1.1);

            for(i in 0...circles.members.length)
            {
                var c = circles.members[i];
                c.scale.set(c.scale.x + 0.1, c.scale.y - 0.1);
            }

            switch(beat)
            {
                case 1:
                    setTxt('ninjamuffin\nphantomArcade\nkawaisprite\nevilsk8er');
                case 3:
                    setTxt('present');
                // credTextShit.text += '\npresent...';
                // credTextShit.addText();
                case 4:
                    setTxt(true);
                case 5:
                    setTxt('In association\nwith');
                case 7:
                    setTxt('newgrounds');
                case 8:
                    setTxt(true);
                case 9:
                    setTxt(randomText[0]);
                case 11:
                    setTxt(randomText[1]);
                case 12:
                    setTxt('Friday', true);
                // credTextShit.visible = true;
                case 13:
                    setTxt('Night');
                // credTextShit.text += '\nNight';
                case 14:
                    setTxt('Funkin');
                case 15: setTxt('Moon Engine');
                case 16: 
                    if(!onTitle)
                    {
                        displayTxt.destroy();
                        onTitle = true;
                        FlxG.camera.flash(FlxColor.WHITE, conductor.crochet / 1000 * 4);
                    }
            }
        });

        getRandomTXT();
        trace('Text of the day: $randomText', "DEBUG");
    }

    public function setTxt(?text:String = '', ?clear:Bool = false)
    {
        if(clear)displayTxt.text = '';
        displayTxt.text += '\n' + text;
        displayTxt.screenCenter();
    }

    final orbitDistance:Float = 130 * 2;
    override public function update(elapsed:Float):Void
    {
        if(FlxG.sound.music != null)
        conductor.time = FlxG.sound.music.time;

        //GlobalMusic.update();

        if(onTitle)
        {
            logo.scale.x = logo.scale.y = FlxMath.lerp(logo.scale.x, 1, elapsed * 10);
            for(i in 0...circles.members.length)
            {
                // my brain got eated
                //pffflllrrtrtrgr
                final circle = circles.members[i];
                final angles = [
                    (Math.PI * 2) * (Date.now().getSeconds() / 60) - Math.PI/2,
                    (Math.PI * 2) * (Date.now().getMinutes() / 60) - Math.PI/2,
                    (Math.PI * 2) * ((Date.now().getHours() % 12 * 60 + Date.now().getMinutes()) / 720) - Math.PI/2
                ];

                final x = FlxG.width / 2 + Math.cos(angles[i]) * orbitDistance;
                final y = FlxG.height / 2 + Math.sin(angles[i]) * orbitDistance;
                circle.scale.set(FlxMath.lerp(circle.scale.x, 1, elapsed * 8), FlxMath.lerp(circle.scale.y, 1, elapsed * 8));
                circle.setPosition(FlxMath.lerp(circle.x, x, elapsed), FlxMath.lerp(circle.y, y, elapsed));
            }
        }

        for(obj in objects)
            obj.visible = onTitle;
    }

    public function getRandomTXT()
    {
        var allTxts = MoonUtils.getArrayFromFile(Paths.data('introTexts.txt'));
        var lines = [];
        for (i in allTxts)
            lines.push(i.split('--'));

        randomText = FlxG.random.getObject(lines);
    }
}
