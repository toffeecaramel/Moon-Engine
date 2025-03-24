package moon.global_obj;

class PixelIcon extends MoonSprite
{
    public var icon(default, set):String;
    public function new(chara:String = 'dummy')
    {
        super();
        this.icon = chara;   
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
    
    @:noCompletion public function set_icon(iconName:String):String
    {
        final actualIcon = (Paths.fileExists('assets/images/ingame/characters/$iconName/icon-ui.png')) ? iconName : 'dummy';
        this.icon = actualIcon;

        final data = Paths.JSON('ingame/characters/$actualIcon/icon-ui_data');

        this.loadGraphic(Paths.image('ingame/characters/$actualIcon/icon-ui'), true, data.frameSize, data.frameSize);
        this.animation.add('idle', [0], 8, false);
        this.animation.add('select', data.frames, 12, false);
        this.antialiasing = data.antialiasing ?? false;
        this.scale.set(data.scale ?? 1, data.scale ?? 1);
        updateHitbox();
        
        this.centerAnimations = true;
        this.playAnim('idle');

        return this.icon;
    }
}