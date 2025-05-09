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
    public var tooLong:Bool = false;

    private var maskShaderSongName:LeftMaskShader;

    //TODO: Color for every character.
    private var glowColor:FlxColor = 0xff00fff2;

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

    function set_text(value:String):String
    {
        if (value == null) return value;
        if (blurredText == null || whiteText == null)
        {
            trace('The MP3Text did not initialize properly', "WARNING");
            return text = value;
        }

        blurredText.text = whiteText.text = value;
        updateTextFilters();

        return text = value;
    }
}