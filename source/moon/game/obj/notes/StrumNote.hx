package moon.game.obj.notes;

class StrumNote extends MoonSprite
{
    public var data:Int;
    public var isCPU:Bool;
    @:isVar public var skin(default, set):String;

    public function new(skin:String, data:Int, isCPU:Bool)
    {
        this.data = data;
        this.isCPU = isCPU;
        super(data);

        this.skin = skin;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed); // need this for animations to work :P
    }

    private function _updtGraphics()
    {
        frames = Paths.getSparrowAtlas('ingame/UI/notes/$skin/strumline');
        
        final dir = MoonUtils.intToDir(data);
        this.centerAnimations = true;

        this.animation.addByPrefix('$dir-static', '$dir-static', 24, true);
        this.animation.addByPrefix('$dir-press', '$dir-press', 24, false);
        this.animation.addByPrefix('$dir-confirm', '$dir-confirm', 24, false);

        this.playAnim('$dir-static', true);

        this.animation.onFinish.add(function(animation:String)
        {
            if(animation == '$dir-confirm') this.playAnim((!this.isCPU) ? '$dir-press' : '$dir-static');
        });
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;
        _updtGraphics();
        return skin;
    }
}