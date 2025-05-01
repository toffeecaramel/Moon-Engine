package moon.game.obj.judgements;

import moon.backend.gameplay.Timings;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
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
    var skin(default, set):String = '';

    /**
     * All the data for this.
     */
    var data:JudgementsJSON;

    /**
     * The color for all the alive numbers;
     */
    var numsColor(default, set):FlxColor;

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
            numbe.y = 0;
            numbe.x = xSep;
            numbe.loadGraphic(Paths.image('ingame/UI/judgements_combo/$skin/numbers/${Std.parseInt(stringArray[i])}'));
            numbe.scale.set(data?.numberScale ?? 1, data?.numberScale ?? 1);
            numbe.antialiasing = data?.antialiasing ?? true;
            numbe.updateHitbox();
			this.add(numbe);

            xSep += numbe.width + data?.numberSpacing ?? 0;
            
            if(animate)
            {
                numbe.y += 25;
                FlxTween.tween(numbe, {y:numbe.y - 25}, 0.24, {ease: FlxEase.quadOut});
            }

            if(fade)
                FlxTween.tween(numbe, {alpha: 0}, 0.4, {startDelay: 0.6 + (0.04 * i)});
		}
    }

    /**
     * Makes a 'roll' animation for the combos (if it exists).
     * @param toNumber The number it will roll to. (IT WILL CHANGE THE COMBO VALUE!!)
     * @param totalRolls Total rolls the combo will do before revealing the combo.
     * @param fadeOut Whether the numbers should fade out after reveal
     */
    function comboRoll(toNumber:Int = 0, ?totalRolls:Int = 5, fadeOut:Bool = false)
    {
        // just so we get the correct amount of numbers, ehehe
        displayCombo(false, false);
        this.combo = toNumber;

        //then we update their graphic
        if(Paths.fileExists('assets/images/ingame/UI/judgements_combo/$skin/numbers/roll.png', IMAGE))
        {
            for (number in this.members)
            {
                //casting it so vsc sees the variables lol
                var num = cast(number, MoonSprite);
                num.graphic = null;
                num.frames = Paths.getSparrowAtlas('ingame/UI/judgements_combo/$skin/numbers/roll');
                num.centerAnimations = true;
                num.color = numsColor;

                num.animation.addByPrefix('roll', 'roll', 24, false);
                num.x += data?.rollOffsets[0] ?? 0;
                num.y += data?.rollOffsets[1] ?? 0;
                num.playAnim('roll', true);
                num.ID = 0;

                final pos = [num.x, num.y];

                //then, the callbacks
                num.animation.onFinish.add((anim) -> 
                {
                    num.ID++;
                    (num.ID >= totalRolls) ? {
                        displayCombo(true, fadeOut);
                        if(toNumber == 0)
                        {
                            numsColor = Timings.getParameters('miss')[4];

                            if(MoonSettings.callSetting('Flashing Lights')) FlxFlicker.flicker(this, 0.5, 0.04, true);
                        }
                    } : num.playAnim('roll', true);
                });

                num.animation.onFrameChange.add((anim, framenum, framind) -> 
                {
                    //little shaking-like effect :P
                    num.x = pos[0] + FlxG.random.float(-6, 6);
                    num.y = pos[1] + FlxG.random.float(-6, 6);
                });
            }
        }
        else displayCombo(true, fadeOut);
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;

        if(Paths.fileExists('assets/images/ingame/UI/judgements_combo/$skin/config.json'))
            data = Paths.JSON('ingame/UI/judgements_combo/$skin/config');
        else throw 'The data .JSON file for the combo and judgements were not found!';

        return this.skin;
    }

    @:noCompletion public function set_numsColor(color:FlxColor):FlxColor
    {
        this.numsColor = color;
        for(num in this.members)num.color = this.numsColor;
        return this.numsColor;    
    }
}