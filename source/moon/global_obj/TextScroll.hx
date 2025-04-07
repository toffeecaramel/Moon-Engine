package moon.global_obj;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

/**
 * Text scroll Class, used for most of the menus! (They look pretty)
 * 
 * Originally made by Funkin' Crew, Modified by Toffee Caramel.
 * All rights reserved to Funkin' Crew, most of this code isn't mine!
 */
class TextScroll extends FlxSpriteGroup
{
    /**
     * The group for all the texts.
     */
    var grpTexts:FlxTypedSpriteGroup<FlxText>;

    /**
     * The screen width.
     */
    public var widthShit:Float = FlxG.width;

    /**
     * Offset placement for each text.
     */
    public var placementOffset:Float = 20;

    /**
     * The text's scroll speed.
     */
    public var speed:Float = 0.8;

    /**
     * The text itself.
     */
    public var text:String;

    /**
     * The size of the texts.
     */
    public var size(default, set):Int = 48;

    /**
     * Creates a scrolling text on the screen.
     * @param x X Position in which the texts will appear.
     * @param y Y Position in which the texts will appear.
     * @param text The text that will show up.
     * @param widthShit The width for each text.
     * @param bold Set whether the texts should be bold or not.
     * @param size Set the size of the texts.
     */
    public function new(x:Float, y:Float, text:String, 
        widthShit:Float = 100, ?size:Int = 48, ?bold:Bool = false)
    {
        super(x, y);

        this.widthShit = widthShit;
        this.text = text;
        if (size != null) this.size = size;

        grpTexts = new FlxTypedSpriteGroup<FlxText>();
        add(grpTexts);

        var testText:FlxText = new FlxText(0, 0, 0, text, this.size);
        testText.font = Paths.font('5by7.ttf');
        testText.bold = bold;
        testText.alpha = 0.0001;
        testText.updateHitbox();
        grpTexts.add(testText);

        var needed:Int = Math.ceil(widthShit / testText.frameWidth) + 5;

        for (i in 0...needed)
        {
            var lmfao:Int = i + 1;

            var coolText:FlxText = new FlxText((lmfao * testText.frameWidth) + (lmfao * 20), 0, 0, text, this.size);

            coolText.font = Paths.font('5by7.ttf');
            coolText.bold = bold;
            coolText.updateHitbox();
            coolText.alpha = 0.0001;
            grpTexts.add(coolText);
        }
    }

    function set_size(value:Int):Int
    {
        if (grpTexts != null)
            grpTexts.forEach(function(txt:FlxText) {txt.size = value;});
        
        this.size = value;
        return value;
    }

    override public function update(elapsed:Float)
    {
        for (txt in grpTexts.group)
        {
            (txt.alpha < 1) ? txt.alpha += 0.01 : txt.alpha = 1;
            txt.x -= 1 * (speed * (elapsed / (1 / 60)));

            if (speed > 0)
            {
                if (txt.x < -txt.frameWidth)
                {
                    txt.x = grpTexts.group.members[grpTexts.length - 1].x + grpTexts.group.members[grpTexts.length - 1].frameWidth + placementOffset;

                    sortTextShit();
                }
            }
            else
            {
                if (txt.x > txt.frameWidth * 2)
                {
                    txt.x = grpTexts.group.members[0].x - grpTexts.group.members[0].frameWidth - placementOffset;

                    sortTextShit();
                }
            }
        }

        super.update(elapsed);
    }

    function sortTextShit():Void
    {
        grpTexts.sort(function(Order:Int, Obj1:FlxObject, Obj2:FlxObject) {
            return FlxSort.byValues(Order, Obj1.x, Obj2.x);
        });
    }
}