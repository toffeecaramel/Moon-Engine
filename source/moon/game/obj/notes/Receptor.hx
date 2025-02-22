package moon.game.obj.notes;

import flixel.group.FlxSpriteGroup;

class Receptor extends FlxSpriteGroup
{
    public var direction:Int = 0;
    public var isCPU:Bool = false;
    @:isVar public var skin(default, set):String = 'vslice';

    public var strumNote:MoonSprite = new MoonSprite();

    public function new(x:Float, y:Float, ?skin:String = 'vslice', direction:Int, isCPU:Bool)
    {
        this.direction = direction;
        this.isCPU = isCPU;
        this.skin = skin;
        super(x, y);

        add(strumNote);
    }

    private function _updtGraphics()
    {
        //strumNote.frames = Paths.getSparrowAtlas();
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;
        _updtGraphics();
        return skin;
    }
}