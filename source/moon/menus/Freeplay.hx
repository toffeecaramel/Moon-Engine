package moon.menus;

import moon.menus.obj.freeplay.FreeplayBG;
import moon.menus.obj.freeplay.AlbumCollection;
import moon.menus.obj.freeplay.FreeplayRank;
import flixel.util.FlxColor;
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
    RANK;
    NONE;
}

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

    public var currentMetadata:MetadataStruct; // The metadata for the current selected song.
    private var conductor:Conductor;
    
    public var mainBG:FreeplayBG;
    public var weekBG:MoonSprite;
    public var capsules:FlxTypedGroup<MP3Capsule> = new FlxTypedGroup<MP3Capsule>();
    public var thisDJ:FreeplayDJ;
    
    public var album:AlbumCollection;
    public var overlay:MoonSprite;
    private var backgroundMus:MoonSound = new MoonSound();

    public function new(character:String = 'bf')
    {
        super();
        this.character = character;

        mainBG = new FreeplayBG(character);

        add(mainBG.behindBG);

        //TODO: Week based BG.
        //TODO: make animations for entering the freeplay
        weekBG = new MoonSprite();
        weekBG.loadGraphic(Paths.image('menus/freeplay/bgs/weekend1'));
        weekBG.scale.set(1.5, 1.5);
        weekBG.antialiasing = true;
        weekBG.updateHitbox();
        add(weekBG);

        weekBG.x = FlxG.width - weekBG.width + 350;
        
        add(mainBG.frontBG);

        thisDJ = new FreeplayDJ(character);
        add(thisDJ);

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
                var caps = new MP3Capsule(-600, 100 + (150 * i), character, chart.content.meta);
                return caps;
            });
        }
        add(capsules);
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

        //(Debug)
        if(FlxG.keys.justPressed.U)
        {
            unlockNewRank(rankOrder[sexo]);
            sexo++;
        }

        if (FlxG.mouse.wheel != 0)
            changeSelection(-FlxG.mouse.wheel);

        updateCapsules(curSelected);

        if(backgroundMus != null && backgroundMus.playing)
        {
            backgroundMus.volume = songVolume;
            backgroundMus.pitch = FlxMath.lerp(backgroundMus.pitch, 1, 0.2);
        }

        if(mainBG.script.exists('onUpdate')) mainBG.script.get('onUpdate')(elapsed);
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, capsules.length - 1);

        for (i in 0...capsules.members.length)
            capsules.members[i].selected = (i == curSelected);

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
    var currentNumb:Int = -1;
    final rankOrder = ['loss', 'good', 'great', 'excellent', 'perfect', 'perfectGold'];
    public function unlockNewRank(rank:String)
    {
        // Current numb is for tracking the current rank in a array
        currentNumb = -1;

        // lower the song volume cus its nicer
        songVolume = 0.1;

        // set the overlay alpha and stuff
        FlxTween.tween(overlay, {alpha: 0.6}, 0.6);
        
        // setup ranks
        var rankDisplay = new FreeplayRank();
        add(rankDisplay);

        //setup the vignette
        var rankVignette = new MoonSprite().loadGraphic(Paths.image('menus/freeplay/rankVignette'));
        rankVignette.alpha = 0.0001;
        rankVignette.blend = ADD;
        //bro wtf
        rankVignette.setGraphicSize(FlxG.width, FlxG.height);
        rankVignette.scale.set(2, 2);
        rankVignette.updateHitbox();
        rankVignette.screenCenter();
        add(rankVignette);

        // makes it so the dj doesn't dance while we're on the rank display stuff.
        thisDJ.canDance = false;

        timer = new FlxTimer().start(0.1, function(_)
        {
            currentNumb++;

            // play the dj anim based on current rank
            thisDJ.anim.play((rank != 'loss') ? 'rankWin' : 'rankLoss', true);

            rankVignette.alpha = 1;
            
            // update rank display size
            rankDisplay.scale.set(2, 2);
            rankDisplay.updateHitbox();
            rankDisplay.screenCenter(); // and also center lol
            rankDisplay.playRank(rankOrder[currentNumb], true);
            
            // tween the camera zoom cause its nice, and shake it a lil is nice too
            FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.2, {ease: FlxEase.backOut});
            FlxG.camera.shake(0.017, 0.2);

            FlxTween.tween(rankVignette, {alpha: 0.0001}, 0.27);

            // play the current rank sfx thing
            Paths.playSFX('${rankOrder[currentNumb]}', 'menus/freeplay/ranks');

            // shake em a lil
            for(i in 0...capsules.members.length)
                capsules.members[i].shakeEffect(7);
            
            //reset the timer if it isn't the supposed rank
            if(rankOrder[currentNumb] != rank) timer.reset(0.35);
            else // proceed to finish the anims and allow player to move (which is a currently todo)
            {
                FlxTween.tween(overlay, {alpha: 0}, 1, {startDelay: 0.5});
                new FlxTimer().start((rank != 'loss') ? 1.3 : 0.7, function(_)
                {
                    // reveal thing
                    final curCapsule = capsules.members[curSelected];
                    Paths.playSFX('${rank}Reveal', 'menus/freeplay/ranks');
                    
                    FlxTween.tween(this, {songVolume: 1}, 1);
                    FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.backInOut});
                    FlxTween.tween(rankDisplay, {"scale.x": 1, "scale.y": 1, x: curCapsule.x + 400, y: curCapsule.y + 40}, 0.5, 
                    {ease: FlxEase.backIn, onComplete: function(_)
                    {
                        for(i in 0...capsules.members.length)
                            capsules.members[i].shakeEffect(16);

                        curCapsule.setRank(rank, true);

                        rankDisplay.destroy();
                        rankVignette.destroy();
                    }});
                });
            }
        });
    }

    function updateCapsules(index:Int):Void
    {
        for (i in 0...capsules.length)
        {
            var capsule = cast capsules.members[i];
            final offsetX = capsuleOffsetX + (capsuleSeparator * 100) / (Math.abs(i - index) + 3);
            final offsetY = capsuleOffsetY + (i - index) * 130;

            capsule.follower.setPosition(offsetX, offsetY);
        }
    }
}