package moon.menus.obj.settings;

import flixel.math.FlxMath;
import moon.dependency.user.MoonSettings.Setting;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

class OptionObject extends FlxSpriteGroup
{
    public var setting:Setting;
    public var category:String;
    
    public var name:FlxText;
    public var value:FlxText;
    public var extra:FlxText;

    public var selected(default, set):Bool = false;

    public function new(?x:Float = 0, ?y:Float = 0, setting:Setting, category:String)
    {
        super(x, y);
        this.setting = setting;
        this.category = category;

        final fontSize = 28;
        final totalWidth:Float = 850;
        final halfWidth:Float = totalWidth * 0.5;

        name = new FlxText(0, 0, halfWidth, setting.name);
        name.setFormat(Paths.font("vcr.ttf"), fontSize, FlxColor.WHITE, LEFT);
        add(name);

        value = new FlxText(halfWidth, 0, halfWidth, Std.string(setting.value));
        value.setFormat(Paths.font("vcr.ttf"), fontSize, FlxColor.WHITE, RIGHT);
        add(value);

        changeValue(0);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(selected)
        {
            if(MoonInput.justPressed(UI_LEFT)) changeValue(-1);
            else if (MoonInput.justPressed(UI_RIGHT)) changeValue(1);
        }
    }

    public function changeValue(amount:Int)
    {
        switch(setting.type)
        {
            case CHECKMARK:
                if(amount != 0)
                    setting.value = !setting.value;
                value.text = (setting.value) ? "< On >" : "< Off >";
            
            case SELECTOR:
                final opts:Array<Dynamic> = setting.options;
                if(opts != null && opts.length > 0)
                {
                    var idx:Int = opts.indexOf(setting.value);
                    if (idx < 0) idx = 0;
                    
                    idx = FlxMath.wrap(idx + amount, 0, opts.length - 1);                    
                    setting.value = opts[idx];
                }

                value.text = '< ${setting.value} >';
            case SLIDER:
                value.text = "WIP!!";
        }
    
        trace('Setting ${setting.name} value is now ${MoonSettings.callSetting(setting.name)}', "DEBUG");

        if(amount != 0)
            MoonSettings.setSetting(setting.name, setting.value);
    }

    @:noCompletion public function set_selected(value:Bool):Bool
    {
        this.selected = value;
        this.color = (selected) ? 0xFFfea711 : 0xffffffff;
        return selected;
    }
}
