package moon.game.submenus;

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
        'resume', 'restart', 'accessibility settings', 'exit'
    ];

    private final ACCESSIBILITY_ITEMS:Array<String> = [
        'botplay', 'practice mode', 'change difficulty'
    ];

    private var currentArray:Array<String> = [];
    private var slideOutItems:Array<Dynamic> = [];

    private final thisFont:String = 'vcr.ttf';

    public var curSelected:Int = 0;

    private var backGradient:FlxSprite;
    private var back:FlxSprite;

    public var pauseItems:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
    public var selector:FlxText = new FlxText();
    var game(get, never):PlayState;

    private var pf:PlayField;

    public function new(camera:FlxCamera)
    {
        super();
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

        cmetadata.antialiasing = false;
        cmetadata.setPosition(120, (metadata.y + cmetadata.height));

        final wawa = [metadata, cmetadata];
        for(i in 0...wawa.length)
            FlxTween.tween(wawa[i], {x: wawa[i].x + 30, alpha: 1}, 0.6, {ease: FlxEase.quadOut, startDelay: 0.2 * i});

        slideOutItems.push(metadata);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        if(MoonInput.justPressed(UI_DOWN)) changeSelection(1);
        if(MoonInput.justPressed(UI_UP)) changeSelection(-1);

        if(MoonInput.justPressed(BACK))
        {
            if(currentArray != DEFAULT_ITEMS) regenItems(DEFAULT_ITEMS);
            else prepareToClose();
        }

        if(MoonInput.justPressed(ACCEPT))
        {
            switch(pauseItems.members[curSelected].text.toLowerCase())
            {
                case 'resume': prepareToClose();
                case 'accessibility settings': regenItems(ACCESSIBILITY_ITEMS);
            }
        }

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

    public function prepareToClose()
    {
        pf.playback.state = PLAY;
        for(member in pf.playback.members) pf.playback.resync(member);
        close();
    }

    @:noCompletion function get_game():PlayState
        return PlayState.playgame;
}