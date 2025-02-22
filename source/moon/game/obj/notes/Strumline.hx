package moon.game.obj.notes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

class Strumline extends FlxTypedSpriteGroup<Receptor>
{
    public function new(x:Float = 0, y:Float = 0, skin:String = 'v-slice', isCPU:Bool = false)
    {
        super(x, y);

        for (i in 0...4)
        {
            this.recycle(Receptor, function():Receptor
            {
                var receptor = new Receptor(0, 0, skin, i, isCPU);
                receptor.setPosition(x, y);
                receptor.x -= ((4 * 0.5) * receptor.strumNote.width);
                receptor.x += (receptor.strumNote.width * i);
                receptor.ID = i;
                return receptor;
            });
        }
    }
}