package moon.game.obj.notes;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup;

class Strumline extends FlxGroup
{
    public var x:Float = 0;
    public var y:Float = 0;

    /**
     * Sets the ID for recognizing this strumline (whether its opponent or not.)
     */
    public var playerID:String;

    public var skin(default, set):String;

    public var isCPU:Bool;

    public var conductor:Conductor;

    public var receptors:FlxTypedGroup<Receptor> = new FlxTypedGroup<Receptor>();

    /**
     * Creates a strumline in screen.
     * @param x         X Position.
     * @param y         Y Position.
     * @param skin      This skin.
     * @param isCPU     Whether is a CPU or not.
     * @param playerID  The player ID for this. can be opponent, p1, etc...
     * @param conductor The conductor, useful for tracking time stuff.
     */
    public function new(x:Float = 0, y:Float = 0, skin:String = 'v-slice', isCPU:Bool = false, playerID:String, conductor:Conductor)
    {
        super();
        this.playerID = playerID;
        this.conductor = conductor;
        this.isCPU = isCPU;
        this.x = x;
        this.y = y;

        this.skin = skin;
    }

    public var boolean:Bool = false;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        //TODO: Remove this, its just a downscroll test. PLACHEOLDER.
        if(FlxG.keys.justPressed.P)
        {
            boolean = !boolean;

            for (i in 0...receptors.members.length)
            FlxTween.tween(receptors.members[i], {y: (boolean) ? 80 : FlxG.height - receptors.members[i].height - 80}, 0.5, {startDelay: 0.05 * i, ease: FlxEase.circOut});
        }
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;
        this.clear();

        for (i in 0...4)
        {
            receptors.recycle(Receptor, function():Receptor
            {
                var receptor = new Receptor(0, 0, skin, i, isCPU, playerID, conductor);
                receptor.setPosition(x, y);

                // yummy emoji
                receptor.x -= ((4 * 0.5) * receptor.strumNote.width);
                receptor.x += (receptor.strumNote.width * i);
                receptor.ID = i;

                return receptor;
            });
        }

        // add everythin' (kinda messy but k)
        add(receptors);
        for(receptor in receptors.members)
        {
            add(receptor.sustainsGroup);
            add(receptor.notesGroup);
            add(receptor.splashGroup);
        }
        return skin;
    }
}