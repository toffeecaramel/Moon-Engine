package moon.menus;

import moon.game.PlayState;
import flixel.effects.FlxFlicker;
import flixel.addons.effects.FlxTrail;
import moon.menus.obj.freeplay.FreeplayBG;
import moon.menus.obj.freeplay.AlbumCollection;
import moon.menus.obj.freeplay.FreeplayRank;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.addons.effects.FlxSkewedSprite;
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
    RANK;
    NONE;
}

//TODO: Doccument freeplay.
class Freeplay extends FlxSubState
{
    public static var appearType:FreeplayTransition = NONE;

    public final songList = ['lit up', 'test1', 'test2', 'test3', 'test4'];
    public var character:String;

    public var curSelected:Int = 0;
    public var songVolume:Float = 1;

    private final capsuleOffsetX:Float = 150;
    private final capsuleOffsetY:Float = 310;
    private final capsuleSeparator:Float = 7;

    public var currentCapsule:MP3Capsule;
    public var currentMetadata:MetadataStruct;
    private var conductor:Conductor;

    public var mainBG:FreeplayBG;
    public var weekBG:FlxSkewedSprite;
    public var capsules:FlxTypedGroup<MP3Capsule> = new FlxTypedGroup<MP3Capsule>();
    public var thisDJ:FreeplayDJ;

    public var album:AlbumCollection;
    public var overlay:MoonSprite;

    private var backgroundMus:MoonSound = new MoonSound();
    private var scrollSnd:MoonSound = new MoonSound();

    public function new(character:String = 'bf')
    {
        //TODO: make animations for entering the freeplay
        super();
        this.character = character;

        mainBG = new FreeplayBG(character);

        add(mainBG.behindBG);

        thisDJ = new FreeplayDJ(character);
        add(thisDJ);

        var behindWeekBG = new FlxSkewedSprite();
        add(behindWeekBG);

        //TODO: Week based BG.
        weekBG = new FlxSkewedSprite();
        weekBG.loadGraphic(Paths.image('menus/freeplay/bgs/week1'));
        weekBG.scale.set(1.4, 1.4);
        weekBG.antialiasing = true;
        weekBG.updateHitbox();
        weekBG.skew.x = 5;
        add(weekBG);

        weekBG.x = FlxG.width - weekBG.width + 360;

        behindWeekBG.makeGraphic(Std.int(weekBG.width), Std.int(weekBG.height), 0xFF000000);
        behindWeekBG.setPosition(weekBG.x - 5, weekBG.y);
        behindWeekBG.skew.x = weekBG.skew.x;

        add(mainBG.frontBG);

        mainBG.script.set('freeplay', this);

        thisDJ.script.set('freeplayMusic', backgroundMus);
        thisDJ.script.set('freeplay', this);

        conductor = new Conductor(0, 4, 4);
        conductor.onBeat.add(function(beat)
        {
            if ((beat % 2 == 0 || conductor.bpm < 120) && thisDJ.canDance)
                thisDJ.anim.play("idle", true);

            if(mainBG.script.exists('onBeat')) mainBG.script.get('onBeat')(beat);
        });

        album = new AlbumCollection(1150, FlxG.height / 2 + 50);
        add(album);

        // Capsules Setup
        for(i in 0...songList.length)
        {
            //TODO
            final chart = new MoonChart(songList[i], 'hard', 'bf');

            capsules.recycle(MP3Capsule, function():MP3Capsule
            {
                var caps = new MP3Capsule(1000, 100 + (200 * i), character, chart.content.meta);
                return caps;
            });
        }
        add(capsules);

        scrollSnd.loadEmbedded(Paths.sound('ui/scrollMenu', 'sounds'));
        FlxG.sound.list.add(scrollSnd);

        changeSelection(curSelected);

        add(mainBG.foreground);

        overlay = new MoonSprite();
        overlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        overlay.alpha = 0;
        add(overlay);

        if(mainBG.script.exists('onCreate')) mainBG.script.call('onCreate');
    }

    var sexo:Int = 0;
    override public function update(elapsed:Float):Void
    {
        conductor.time = backgroundMus.time;
        super.update(elapsed);

        album.angle = FlxMath.lerp(album.angle, 16, 0.2);

        if (MoonInput.justPressed(UI_UP)) changeSelection(-1);
        if (MoonInput.justPressed(UI_DOWN)) changeSelection(1);

        if (MoonInput.justPressed(ACCEPT))
        {
            Global.allowInputs = false;
            Paths.playSFX('ui/confirmMenu');

            thisDJ.canDance = false;
            thisDJ.anim.play("confirm", true);
            if(mainBG.script.exists('onConfirm')) mainBG.script.call('onConfirm');

            currentCapsule.confirm();

            //TODO: difficulty support awawa!!
            //TODO: loading screen
            new FlxTimer().start(1.2, (_) -> FlxG.switchState(() -> 
            {
                Paths.clearStoredMemory();
                new PlayState(songList[curSelected], 'hard', character);
            }));
        }

        if (FlxG.mouse.wheel != 0 && Global.allowInputs)
            changeSelection(-FlxG.mouse.wheel);

        //(Debug)
        if(FlxG.keys.justPressed.U)
        {
            unlockNewRank(rankOrder[sexo]);
            sexo++;
        }
        if(FlxG.keys.justPressed.R)//lol
            FlxG.switchState(() -> new PlayState('roses', 'nightmare', character));

        updateCapsules(curSelected);

        if(backgroundMus != null && backgroundMus.playing)
        {
            backgroundMus.volume = songVolume;
            backgroundMus.pitch = FlxMath.lerp(backgroundMus.pitch, 1, 0.2);
        }

        if(mainBG.script.exists('onUpdate')) mainBG.script.get('onUpdate')(elapsed);
    }

    function updateCapsules(index:Int):Void
    {
        for (i in 0...capsules.length)
        {
            final capsule = cast capsules.members[i];
            final offsetX = capsuleOffsetX + (capsuleSeparator * 100) / (Math.abs(i - index) + 3);
            final offsetY = capsuleOffsetY + (i - index) * 130;

            capsule.follower.setPosition(offsetX, offsetY);
        }
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, capsules.length - 1);

        for (i in 0...capsules.members.length)
            capsules.members[i].selected = (i == curSelected);

        currentCapsule = capsules.members[curSelected];

        scrollSnd.pitch = 1;
        playScrollSFX();

        //TODO: Difficulties change and shitt
        final ch = new MoonChart(songList[curSelected], 'hard', character);
        currentMetadata = ch.content.meta;

        album.switchToAlbum(currentMetadata.album);

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
            backgroundMus.pitch = 0.1;
            backgroundMus.volume = songVolume;
            FlxG.sound.list.add(backgroundMus);
            
            //TODO: GET SONGS TIME SIGNATURE TO WORK!!
            conductor.changeBpmAt(0, currentMetadata.bpm, 4, 4);
        }, true);
    }
    
    var timer:FlxTimer;
    var currentNumb:Int = 0;
    final rankOrder = ['loss', 'good', 'great', 'excellent', 'perfect', 'perfectGold'];
    public function unlockNewRank(rank:String):Void
    {
        var delay:Float = 0.05;

        Global.allowInputs = false; //Disable inputs.
        songVolume = 0.1;
        scrollSnd.pitch = 0.6;
        FlxTween.tween(overlay, {alpha: 0.6}, 0.4);

        // Create a new rank display and vignette.
        var rankDisplay:FreeplayRank = new FreeplayRank();
        add(rankDisplay);

        var rankVignette:MoonSprite = new MoonSprite();
        rankVignette.loadGraphic(Paths.image('menus/freeplay/rankVignette'));
        rankVignette.alpha = 0.0001;
        rankVignette.blend = ADD;
        rankVignette.setGraphicSize(FlxG.width, FlxG.height);
        rankVignette.scale.set(2, 2);
        rankVignette.updateHitbox();
        rankVignette.screenCenter();
        add(rankVignette);

        // Prevent the DJ from dancing during the rank reveal
        thisDJ.canDance = false;
        
        final targetIndex = rankOrder.indexOf(rank);
        currentNumb = 0; // always start at "loss"
        
        // Start the timer loop
        timer = new FlxTimer();
        timer.start(delay, function(_)
        {
            // Update the rank display with current rank.
            rankDisplay.scale.set(2, 2);
            rankDisplay.updateHitbox();
            rankDisplay.screenCenter();
            rankDisplay.setRank(rankOrder[currentNumb], true);
            
            thisDJ.anim.play((rankOrder[currentNumb] != 'loss') ? 'rankWin' : 'rankLoss', true);
            //Paths.playSFX('${rankOrder[currentNumb]}', 'menus/freeplay/ranks');
            
            // Slightly shake capsules.
            for (i in 0...capsules.members.length)
                capsules.members[i].shakeEffect(2);
            
            // Camera ztuff
            FlxG.camera.zoom += 0.04;
            FlxG.camera.shake(0.002, 0.2);

            //scroll snd bc yeah its cool
            scrollSnd.pitch += 0.2;
            playScrollSFX();
            
            // If we have not yet reached the target rank, increment and reset the timer wrawrwaf
            if (currentNumb < targetIndex)
            {
                currentNumb++;
                delay += 0.1;
                timer.reset(delay);
            }
            else
            {
                timer.cancel();
                finishRankUnlock(rank, rankDisplay, rankVignette);
            }
        });
    }

    function finishRankUnlock(rank:String, rankDisplay:FreeplayRank, rankVignette:MoonSprite):Void
    {
        FlxFlicker.flicker(rankDisplay, 0.8, 0.06, true);

        var trail = new FlxTrail(rankDisplay.rankSprite, null, 18, 2, 0.5, 0.069);
        trail.color = rankDisplay.getRankColor();
        trail.blend = ADD;
        add(trail);
        
        rankDisplay.scale.set(0.2, 0.2);
        FlxTween.tween(rankDisplay, {"scale.x": 2, "scale.y": 2}, 0.6, {ease: FlxEase.backOut});
        Paths.playSFX('menus/freeplay/ranks/$rank');
        
        var trailShake = FlxTween.shake(trail, 0.02, 10, XY);

        new FlxTimer().start((rank != 'loss') ? 1.3 : 0.74, (_) -> Paths.playSFX('menus/freeplay/ranks/${rank}Reveal'));
        FlxTween.tween(rankDisplay, { "scale.x": 1, "scale.y": 1, x: currentCapsule.x + 400, y: currentCapsule.y + 40 }, 0.5,
        {
            ease: FlxEase.backIn,
            startDelay: (rank != 'loss') ? 1.2 : 0.64,
            onComplete: function(_)
            {
                FlxTween.tween(FlxG.camera, { zoom: 1 }, 0.8, { ease: FlxEase.expoOut });
                for (i in 0...capsules.members.length)
                    capsules.members[i].shakeEffect(24);
                currentCapsule.setRank(rank, true);
                
                rankVignette.alpha = 0.6;
                FlxTween.tween(rankVignette, { alpha: 0.0001 }, 0.2,
                {ease: FlxEase.quadIn, onComplete: (_) -> rankVignette.destroy()});
                trailShake.cancel();
                rankDisplay.destroy();
                trail.kill();
                Global.allowInputs = true; //Then allow inputs back.
            }
        });
        
        FlxTween.tween(this, { songVolume: 1 }, 1);
        FlxTween.tween(overlay, { alpha: 0 }, 0.6, { startDelay: 0.3 });
    }

    private function playScrollSFX()
    {
        if(scrollSnd.playing) scrollSnd.stop();
        scrollSnd.play();
    }
}