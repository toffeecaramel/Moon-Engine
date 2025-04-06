package moon.menus;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import moon.dependency.MoonChart.MetadataStruct;
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

    public final songList = ['lit up', 'lit up', 'lit up', 'lit up', 'lit up', 'lit up', 'lit up', 'lit up', 'lit up', 'lit up', 'lit up'];
    public var character:String;

    public var curSelected:Int = 0;
    public var songVolume:Float = 1;

    private final capsuleOffsetX:Float = 150;
    private final capsuleOffsetY:Float = 310;
    private final capsuleSeparator:Float = 7;

    public var currentMetadata:MetadataStruct; // The metadata for the current selected song.
    private var conductor:Conductor;
    
    private var capsules:FlxTypedGroup<MP3Capsule> = new FlxTypedGroup<MP3Capsule>();
    public var thisDJ:FreeplayDJ;

    private var backgroundMus:MoonSound = new MoonSound();

    private var album:MoonSprite;

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

        album = new MoonSprite();
        add(album);
        changeSelection(curSelected);
    }

    override public function update(elapsed:Float):Void
    {
        conductor.time = backgroundMus.time;
        super.update(elapsed);

        album.angle = FlxMath.lerp(album.angle, 16, 0.2);

        if (MoonInput.justPressed(UI_UP)) changeSelection(-1);
        if (MoonInput.justPressed(UI_DOWN)) changeSelection(1);

        //(Debug)
        if(FlxG.keys.justPressed.U) unlockNewRank('perfectGold');

        if (FlxG.mouse.wheel != 0)
            changeSelection(-FlxG.mouse.wheel);

        updateCapsules(curSelected);

        if(backgroundMus != null && backgroundMus.playing) backgroundMus.volume = songVolume;
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, capsules.length - 1);

        for (i in 0...capsules.members.length)
            capsules.members[i].selected = (i == curSelected);

        //TODO: Difficulties change and shitt
        final ch = new MoonChart(songList[curSelected], 'hard', character);
        currentMetadata = ch.content.meta;

        album.loadGraphic(Paths.image('menus/freeplay/albums/${currentMetadata.album}'));
        album.x = (FlxG.width - album.width) - 32;
        album.angle = 0;
        album.screenCenter(Y);

        // Load the current selected song.
        new Future(() -> 
        {
            if(backgroundMus != null)
            {
                FlxG.sound.list.remove(backgroundMus);
                backgroundMus.stop();
            }

            backgroundMus.loadEmbedded(Paths.sound('${songList[curSelected]}/$character/Inst', 'songs'), true);
            backgroundMus.play();
            backgroundMus.pitch = 0;
            backgroundMus.volume = songVolume;
            backgroundMus.pitchTween(1, 1, FlxEase.quadOut);
            FlxG.sound.list.add(backgroundMus);

            //TODO: GET SONGS TIME SIGNATURE TO WORK!!
            conductor.changeBpmAt(0, currentMetadata.bpm, 4, 4);
        }, true);
    }

    var timer:FlxTimer;
    var currentNumb:Int = -1;
    public function unlockNewRank(rank:String)
    {
        var rankVignette = new MoonSprite().loadGraphic(Paths.image('menus/freeplay/rankVignette'));
        rankVignette.alpha = 0.0001;
        rankVignette.blend = ADD;
        //bro wtf
        rankVignette.setGraphicSize(FlxG.width, FlxG.height);
        rankVignette.scale.set(2, 2);
        rankVignette.screenCenter();
        add(rankVignette);

        var rankDisplay = new MoonSprite();
        rankDisplay.frames = Paths.getSparrowAtlas('menus/freeplay/rankbadges');
        rankDisplay.animation.addByPrefix('loss', 'LOSS rank0', 24, false);
        rankDisplay.animation.addByPrefix('good', 'GOOD rank0', 24, false);
        rankDisplay.animation.addByPrefix('great', 'GREAT rank0', 24, false);
        rankDisplay.animation.addByPrefix('excellent', 'EXCELLENT rank0', 24, false);
        rankDisplay.animation.addByPrefix('perfect', 'PERFECT rank0', 24, false);
        rankDisplay.animation.addByPrefix('perfectGold', 'PERFECT rank GOLD0', 24, false);
        rankDisplay.centerAnimations = true;
        rankDisplay.alpha = 0;
        rankDisplay.antialiasing = true;
        add(rankDisplay);

        thisDJ.canDance = false;

        final rankOrder = ['loss', 'good', 'great', 'excellent', 'perfect', 'perfectGold'];
        timer = new FlxTimer().start(0.1, function(_)
        {
            currentNumb++;
            thisDJ.anim.play('rankWin', true);
            rankVignette.alpha = 0.9;
            FlxTween.tween(rankVignette, {alpha: 0.0001}, 0.3);

            rankDisplay.alpha = 1;
            rankDisplay.scale.set(2, 2);
            rankDisplay.screenCenter();
            
            rankDisplay.playAnim(rankOrder[currentNumb], true);
            FlxG.camera.shake(0.03, 0.2);
            
            if(rankOrder[currentNumb] != rank) timer.reset(0.8);
        });
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