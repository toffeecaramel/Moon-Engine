package moon.menus.obj.freeplay;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import flixel.util.FlxColor;
import moon.hardcoded_shaders.GaussianBlurShader;
import moon.hardcoded_shaders.LeftMaskShader;

/**
 * An text that glows and also extends/cuts its size.
 * Most of the code was taken from FNF's one.
 */
class MP3Text extends FlxSpriteGroup
{
    public var blurredText:FlxText;
    public var whiteText:FlxText;
    public var text(default, set):String;
    public var clipWidth(default, set):Int = 255;
    public var tooLong:Bool = false;

    private var maskShaderSongName:LeftMaskShader;

    //TODO: Color for every character.
    private var glowColor:FlxColor = 0xff00fff2;
    private var moveTimer:FlxTimer;
    private var moveTween:FlxTween;
    private var flickerTimer:FlxTimer;
    private var flickerState:Bool = false;

    public function new(?x:Float = 0, ?y:Float = 0, songTitle:String, size:Float)
    {
        super(x, y);

        maskShaderSongName = new LeftMaskShader();

        blurredText = initText(songTitle, size);
        blurredText.shader = new GaussianBlurShader(1);
        blurredText.color = glowColor;

        whiteText = initText(songTitle, size);
        whiteText.color = FlxColor.WHITE;

        add(blurredText);
        add(whiteText);

        initMove();
        applyStyle();

        this.text = songTitle;
    }

    private function initText(songTitle:String, size:Float):FlxText
    {
        var text = new FlxText(0, 0, 0, songTitle, Std.int(size));
        text.font = Paths.font("5by7.ttf");
        return text;
    }

    public function applyStyle():Void
    {
        //TODO: glowColor = characterglowcolor
        //glowColor = FlxColor.CYAN;
        blurredText.color = glowColor;
        updateTextFilters();
    }

    private function updateTextFilters():Void
    {
        whiteText.textField.filters = [
            new GlowFilter(glowColor, 1, 5, 5, 210, BitmapFilterQuality.MEDIUM)
        ];
    }

    function set_clipWidth(value:Int):Int
    {
        resetText();
        checkClipWidth(value);
        return clipWidth = value;
    }

    function checkClipWidth(?wid:Int):Void
    {
        wid = wid ?? clipWidth;

        if (whiteText.width > wid)
        {
            tooLong = true;
            var clipRect = new FlxRect(0, 0, wid, whiteText.height);
            blurredText.clipRect = clipRect;
            whiteText.clipRect = clipRect;
        }
        else
        {
            tooLong = false;
            blurredText.clipRect = null;
            whiteText.clipRect = null;
        }
    }

    function set_text(value:String):String
    {
        if (value == null) return value;
        if (blurredText == null || whiteText == null)
        {
            trace('The MP3Text did not initialize properly', "WARNING");
            return text = value;
        }

        blurredText.text = whiteText.text = value;
        checkClipWidth();
        updateTextFilters();

        return text = value;
    }

    public function initMove():Void
    {
        if(width >= 250)
        moveTimer = new FlxTimer().start(0.8, (_) -> moveTextRight());
    }

    function moveTextRight():Void
    {
        var distToMove:Float = whiteText.width - clipWidth;
        moveTween = FlxTween.tween(whiteText.offset, {x: distToMove}, 2,
        {
            onUpdate: updateTextClip,
            onComplete: (_) -> moveTimer.start(0.8, (_) -> moveTextLeft()),
            ease: FlxEase.sineInOut
        });
    }

    function moveTextLeft():Void
    {
        moveTween = FlxTween.tween(whiteText.offset, {x: 0}, 2,
        {
            onUpdate: updateTextClip,
            onComplete: (_) -> moveTimer.start(0.8, (_) -> moveTextRight()),
            ease: FlxEase.sineInOut
        });
    }

    function updateTextClip(_):Void
    {
        var clipRect = new FlxRect(whiteText.offset.x, 0, clipWidth, whiteText.height);
        whiteText.clipRect = clipRect;
        blurredText.offset = whiteText.offset;
        blurredText.clipRect = clipRect;
    }

    public function resetText():Void
    {
        if (moveTween != null) moveTween.cancel();
        if (moveTimer != null) moveTimer.cancel();
        whiteText.offset.x = blurredText.offset.x = 0;
        updateTextClip(null);
    }

    public function flickerText():Void
    {
        resetText();
        flickerTimer = new FlxTimer().start(1 / 24, flickerProgress, 19);
    }

    function flickerProgress(_):Void
    {
        if (flickerState)
        {
            whiteText.blend = blurredText.blend = BlendMode.ADD;
            blurredText.color = whiteText.color = FlxColor.WHITE;
            whiteText.textField.filters = [new GlowFilter(FlxColor.WHITE, 1, 5, 5, 210, BitmapFilterQuality.MEDIUM)];
        }
        else
        {
            blurredText.color = glowColor;
            whiteText.color = 0xFFDDDDDD;
            updateTextFilters();
        }
        flickerState = !flickerState;
    }
}