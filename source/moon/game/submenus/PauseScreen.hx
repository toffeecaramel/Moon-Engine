package moon.game.submenus;

import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import moon.global_obj.PixelIcon;
import moon.game.obj.PlayField;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.display.BlendMode;
import flixel.util.FlxGradient;

class PauseScreen extends FlxSubState
{
    private final DEFAULT_ITEMS:Array<String> = [
        'resume', 'restart', 'settings', 'accessibility settings', 'exit'
    ];

    private final ACCESSIBILITY_ITEMS:Array<String> = [
        'botplay', 'practice mode', 'change difficulty'
    ];

    private var currentArray:Array<String> = [];
    private var slideOutItems:Array<Dynamic> = [];

    private final thisFont:String = 'vcr.ttf';

    public var curSelected:Int = 0;

    public var canMove:Bool;

    private var backGradient:FlxSprite;
    private var back:FlxSprite;

    private var displayIcon:PixelIcon;

    public var pauseItems:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
    public var selector:FlxText = new FlxText();
    var game(get, never):PlayState;

    private var pf:PlayField;

    public function new(camera:FlxCamera)
    {
        super();
        canMove = true;
        this.camera = camera;
        pf = game.playField; // NAO NAO É UM PRATO FEITO E PLAYFIELD!!!!

        backGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0x00000000, 0xFF001A83], 1, 180);
        backGradient.alpha = 0;
        add(backGradient);
        FlxTween.tween(backGradient, {alpha: 0.7}, 0.4);

        back = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        back.alpha = 0;
        back.blend = BlendMode.DIFFERENCE;
        add(back);
        FlxTween.tween(back, {alpha: 0.5}, 0.4);

        var paused = new MoonSprite(-800, 45).loadGraphic(Paths.image('menus/pause/ps'));
        paused.scale.set(0.8, 0.8);
        paused.antialiasing = true;
        paused.updateHitbox();
        add(paused);
        slideOutItems.push(paused);
        FlxTween.tween(paused, {x: 75}, 1.3, {ease: FlxEase.expoOut});

        regenItems(DEFAULT_ITEMS);
        add(pauseItems);

        selector.text = '>>';
        selector.setFormat(Paths.font(thisFont), 32, FlxColor.WHITE, LEFT);
        add(selector);

        // < ADD METADATA > //
        //(chart content)
        final cc = pf.chart.content;
        var metadata = new FlxText();
        metadata.text = '${cc.meta.artist} - ${pf.song.toUpperCase()} (${pf.mix.toUpperCase()} MIX)';
        metadata.setFormat(Paths.font(thisFont), 20, FlxColor.WHITE, LEFT);
        metadata.alpha = 0;
        add(metadata);

        slideOutItems.push(metadata);

        metadata.textField.antiAliasType = ADVANCED;
        metadata.textField.sharpness = 400;
        metadata.antialiasing = false;
        metadata.setPosition(120, (FlxG.height - metadata.height) - 48);

        var cmetadata = new FlxText();
        cmetadata.text = 'Chart: ${cc.meta.charter}';
        cmetadata.setFormat(Paths.font(thisFont), metadata.size, FlxColor.WHITE, LEFT);
        cmetadata.alpha = 0;
        cmetadata.textField.antiAliasType = metadata.textField.antiAliasType;
        cmetadata.textField.sharpness = metadata.textField.sharpness;
        add(cmetadata);

        slideOutItems.push(cmetadata);

        cmetadata.antialiasing = false;
        cmetadata.setPosition(120, (metadata.y + cmetadata.height));

        displayIcon = new PixelIcon(cc.meta.opponents[0]);
        displayIcon.alpha = 0;
        add(displayIcon);

        slideOutItems.push(displayIcon);
        
        displayIcon.setPosition((metadata.x - displayIcon.width) + 12, (metadata.y - (displayIcon.height / 2)) + 12);

        final wawa = [metadata, displayIcon, cmetadata];
        for(i in 0...wawa.length)
            FlxTween.tween(wawa[i], {x: wawa[i].x + 30, alpha: 1}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.1 * i});

        FlxG.sound.play(Paths.sound('game/pause/onPause', 'sounds'));
    }

    override public function update(elapsed:Float)
    {
        if(MoonInput.justPressed(UI_DOWN) && canMove) changeSelection(1);
        if(MoonInput.justPressed(UI_UP) && canMove) changeSelection(-1);

        if(MoonInput.justPressed(BACK) && canMove)
        {
            if(currentArray != DEFAULT_ITEMS) regenItems(DEFAULT_ITEMS);
            else prepareToClose(true);
        }

        if(MoonInput.justPressed(ACCEPT) && canMove)
        {
            switch(pauseItems.members[curSelected].text.toLowerCase())
            {
                case 'resume': prepareToClose();
                case 'accessibility settings': regenItems(ACCESSIBILITY_ITEMS);
            }
        }

        super.update(elapsed);

        if(pauseItems.members.length > 0)
        {
            final item = pauseItems.members[curSelected];
            selector.setPosition(FlxMath.lerp(selector.x, item.x - 42, 0.2), FlxMath.lerp(selector.y, item.y, 0.2));
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, pauseItems.members.length - 1);
    }

    public function regenItems(items:Array<String>)
    {
        currentArray = items;
        pauseItems.clear();
        
        for (i in 0...items.length)
        {
            final item = items[i];
            pauseItems.recycle(FlxText, function():FlxText
            {
                var hi = new FlxText(120, 250 + (45 * i), 500, item.toUpperCase());
                hi.setFormat(Paths.font(thisFont), 32, FlxColor.WHITE, LEFT);
                hi.alpha = 0;
                hi.textField.antiAliasType = ADVANCED;
                hi.textField.sharpness = 400;
                FlxTween.tween(hi, {x: hi.x + 30, alpha: 1}, 0.4, {ease: FlxEase.quadOut, startDelay: 0.1 * i});
                return hi;
            });
        }

        selector.setPosition(-100, pauseItems.members[0].y);
        changeSelection(0);
    }

    public function prepareToClose(?pressedEsc:Bool = false)
    {
        canMove = false;
        for (c in pauseItems.members) slideOutItems.push(c);
        displayIcon.playAnim('select', true);

        if(!pressedEsc)FlxFlicker.flicker(pauseItems.members[curSelected], 1, 0.05, true);
        new FlxTimer().start(1, function(_)
        {
            for (item in slideOutItems) FlxTween.tween(item, {x: item.x - 700}, 0.6, {ease: FlxEase.expoIn});

            //pf.playback.state = PLAY;
            //for(member in pf.playback.members) pf.playback.resync(member);
            //close();
        });
    }

    @:noCompletion function get_game():PlayState
        return PlayState.playgame;
}