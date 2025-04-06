package moon.menus;

import flixel.tweens.FlxEase;
import lime.app.Future;
import moon.menus.obj.freeplay.FreeplayDJ;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.FlxState;
import moon.menus.obj.freeplay.MP3Capsule;

enum FreeplayTransition
{
    FADE;
    STICKERS;
    NONE;
}
class Freeplay extends FlxSubState
{
    public static var appearType:FreeplayTransition = NONE;

    public final songList = ['lit up', 'lit up', 'lit up', 'lit up', 'lit up', 'lit up'];
    public var character:String;

    public var curSelected:Int = 0;
    public var songVolume:Float = 1;

    private final capsuleOffsetX:Float = 150;
    private final capsuleOffsetY:Float = 310;
    private final capsuleSeparator:Float = 7;

    private var conductor:Conductor;
    
    private var capsules:FlxTypedGroup<MP3Capsule> = new FlxTypedGroup<MP3Capsule>();
    public var thisDJ:FreeplayDJ;

    private var backgroundMus:MoonSound = new MoonSound();

    public function new(character:String = 'bf')
    {
        super();
        this.character = character;
        
        thisDJ = new FreeplayDJ(character);
        add(thisDJ);
        thisDJ.script.set('freeplayMusic', backgroundMus);
        thisDJ.script.set('freeplay', this);

        conductor = new Conductor(0, 4, 4);
        conductor.onBeat.add(function(beat)
        {
            if (beat % 2 == 0 && thisDJ.canDance)
                thisDJ.anim.play("idle", true);
        });

        // Capsules Setup
        for(i in 0...songList.length)
        {
            //TODO 
            final chart = new MoonChart(songList[i], 'hard', 'bf');

            capsules.recycle(MP3Capsule, function():MP3Capsule
            {
                var caps = new MP3Capsule(-600, 100 + (150 * i), character, chart.content.meta);
                return caps;
            });
        }

        add(capsules);
        changeSelection(curSelected);
    }

    override public function update(elapsed:Float):Void
    {
        conductor.time = backgroundMus.time;
        super.update(elapsed);

        if (MoonInput.justPressed(UI_UP)) changeSelection(-1);
        if (MoonInput.justPressed(UI_DOWN)) changeSelection(1);

        if (FlxG.mouse.wheel != 0)
            changeSelection(-FlxG.mouse.wheel);

        if(backgroundMus != null) backgroundMus.volume = songVolume;

        updateCapsules(curSelected);
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, capsules.length - 1);

        for (i in 0...capsules.members.length)
            capsules.members[i].selected = (i == curSelected);

        // Load the current selected song.
        new Future(() -> 
        {
            if(backgroundMus != null)
            {
                FlxG.sound.list.remove(backgroundMus);
                backgroundMus.stop();
            }

            final ch = new MoonChart(songList[curSelected], 'hard', character);

            backgroundMus.loadEmbedded(Paths.sound('${songList[curSelected]}/$character/Inst', 'songs'), true);
            backgroundMus.play();
            backgroundMus.pitch = 0;
            backgroundMus.volume = songVolume;
            backgroundMus.pitchTween(1, 1, FlxEase.quadOut);
            FlxG.sound.list.add(backgroundMus);

            //TODO: GET SONGS TIME SIGNATURE TO WORK!!
            conductor.changeBpmAt(0, ch.content.meta.bpm, 4, 4);
        }, true);
    }

    function updateCapsules(index:Int):Void
    {
        for (i in 0...capsules.length)
        {
            var capsule = cast capsules.members[i];
            final offsetX = capsuleOffsetX + (capsuleSeparator * 100) / (Math.abs(i - index) + 3);
            final offsetY = capsuleOffsetY + (i - index) * 130;
            final lerp = 0.3;

            capsule.setPosition(FlxMath.lerp(capsule.x, offsetX, lerp), FlxMath.lerp(capsule.y, offsetY, lerp));
        }
    }
}