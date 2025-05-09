package moon.menus;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import moon.game.PlayState;
import moon.menus.obj.freeplay.*;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSubState;

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

    public var songVolume:Float = 1;
    private var conductor:Conductor;

    public var mainBG:FreeplayBG;
    public var weekBG:FlxSkewedSprite;
    public var thisDJ:FreeplayDJ;

    public function new(character:String = 'bf')
    {
        //TODO: make animations for entering the freeplay
        super();
        this.character = character;

        mainBG = new FreeplayBG(character);

        add(mainBG.behindBG);

        thisDJ = new FreeplayDJ(character);
        add(thisDJ);

        //TODO: Week based BG.
        weekBG = new FlxSkewedSprite();
        weekBG.loadGraphic(Paths.image('menus/freeplay/bgs/week1'));
        weekBG.scale.set(1.4, 1.4);
        weekBG.antialiasing = true;
        weekBG.updateHitbox();
        weekBG.skew.x = 5;
        add(weekBG);

        weekBG.x = FlxG.width - weekBG.width + 360;
        add(mainBG.frontBG);

        mainBG.script.set('freeplay', this);
        thisDJ.script.set('freeplay', this);

        conductor = new Conductor(0, 4, 4);
        conductor.onBeat.add(function(beat)
        {
            if ((beat % 2 == 0 || conductor.bpm < 120) && thisDJ.canDance)
                thisDJ.anim.play("idle", true);

            if(mainBG.script.exists('onBeat')) mainBG.script.get('onBeat')(beat);
        });

        add(mainBG.foreground);

        var txt = new FlxText();
        txt.text = 'Seven. Seven humans souls and the king ASGORE...\n' +
        '*COUGH* ahem- i mean-\n' +
        'S For Senpai Noimix\n' +
        'R for Roses Noimix\n' +
        'T for Thorns Noimix\n' +
        'A for thorns erect by agua thanks aguacrunch you are so fucking gay\n' +
        'F for Final Stretch (Indie Cross)\n' +
		'U for Unbeatable not indie cross but marios madness\n' + 
        'M for monster booo lame\n' +
		'\n Chicos... estoy comendo mortadelaa,,,';
        txt.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.BLACK, CENTER);
        txt.setBorderStyle(OUTLINE, FlxColor.CYAN, 10);
        add(txt);
        txt.screenCenter();

        if(mainBG.script.exists('onCreate')) mainBG.script.call('onCreate');
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.S)//lol
            FlxG.switchState(() -> new PlayState('senpai', 'hard', 'noimix'));

        if(FlxG.keys.justPressed.R)//lol
            FlxG.switchState(() -> new PlayState('roses', 'hard', 'noimix'));

        if(FlxG.keys.justPressed.T)//lol
            FlxG.switchState(() -> new PlayState('thorns', 'hard', 'noimix'));

        if(FlxG.keys.justPressed.A)//lol
            FlxG.switchState(() -> new PlayState('thorns', 'erect', 'agua'));

        if(FlxG.keys.justPressed.F)//lol
            FlxG.switchState(() -> new PlayState('final stretch', 'hard', 'bf'));
			
        if(FlxG.keys.justPressed.U)//lol
            FlxG.switchState(() -> new PlayState('unbeatable', 'hard', 'bf'));

        if(FlxG.keys.justPressed.M)//lol
            FlxG.switchState(() -> new PlayState('monster', 'hard', 'bf'));
			
        if(mainBG.script.exists('onUpdate')) mainBG.script.get('onUpdate')(elapsed);
    }
}