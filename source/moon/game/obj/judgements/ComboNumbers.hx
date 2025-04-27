package moon.game.obj.judgements;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;

@:publicFields
class ComboNumbers extends FlxSpriteGroup
{
    /**
     * The combo's numbers. Always remember to update this before displaying it.
     */
    var combo:Int = 0;

    /**
     * The combo's skin display.
     */
    var skin:String = '';

    /**
     * All the data for this.
     */
    var data:JudgementsJSON;

    /**
     * Starts the combo and reads its data (if exists.)
     * @param skin This combo's skin name.
     */
    function init(skin:String)
    {
        this.skin = skin;

        if(Paths.fileExists('assets/images/ingame/UI/judgements_combo/$skin/config.json'))
            data = Paths.JSON('ingame/UI/judgements_combo/$skin/config');
        else throw 'The data .JSON file for the combo and judgements were not found!';

        return this;
    }

    var xSep:Float = 0;

    /**
     * Displays the combo numbers on screen
     * @param animate Whether it should do a 'jump' animation or not.
     * @param fade Whether it should do a fade out or not.
     */
    function displayCombo(animate:Bool = true, fade:Bool = true)
    {
        this.clear();
        var comboString:String = Std.string(combo);
		var stringArray:Array<String> = comboString.split("");
        xSep = 0;

		for (i in 0...stringArray.length)
		{
			var numbe = recycle(MoonSprite);
            numbe.x = xSep;
            numbe.loadGraphic(Paths.image('ingame/UI/judgements_combo/$skin/numbers/${Std.parseInt(stringArray[i])}'));
            numbe.scale.set(data.numberScale, data.numberScale);
            numbe.updateHitbox();
            numbe.antialiasing = data.antialiasing;
			this.add(numbe);

            xSep += numbe.width + data.numberSpacing;
            
            if(animate)
            {
                numbe.velocity.y = -FlxG.random.int(140, 160);   
                numbe.acceleration.y = FlxG.random.int(200, 300);
            }

            if(fade)
                FlxTween.tween(numbe, {alpha: 0}, 0.4, {startDelay: 0.6 + (0.04 * i)});
		}
    }

    /**
     * Makes a 'roll' animation for the combos (if it exists).
     * @param toNumber The number it will roll to.
     * @param fadeOut Whether the numbers should fade out after reveal
     */
    function comboRoll(toNumber:Int = 0, fadeOut:Bool = false)
    {

    }
}