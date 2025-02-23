package moon.game.obj.notes;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup;

class Strumline extends FlxGroup
{
    /**
     * Sets the ID for recognizing this strumline (whether its opponent or not.)
     */
    public var strumID:String;

    public var receptors:FlxTypedGroup<Receptor> = new FlxTypedGroup<Receptor>();

    /**
     * Creates a strumline on screen.
     * @param x 
     * @param y 
     * @param skin 
     * @param isCPU 
     */
    public function new(x:Float = 0, y:Float = 0, skin:String = 'v-slice', isCPU:Bool = false)
    {
        super();

        for (i in 0...4)
        {
            receptors.recycle(Receptor, function():Receptor
            {
                var receptor = new Receptor(0, 0, skin, i, isCPU);
                receptor.setPosition(x, y);
                // yummy emoji
                receptor.x -= ((4 * 0.5) * receptor.strumNote.width);
                receptor.x += (receptor.strumNote.width * i);
                receptor.ID = i;

                return receptor;
            });
        }

        add(receptors);
        for(receptor in receptors.members) add(receptor.notesGroup);
    }
}