package moon.menus.obj.settings;

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
    }

    @:noCompletion public function set_selected(value:Bool):Bool
    {
        this.selected = value;

        this.color = (selected) ? 0xFFfea711 : 0xffffffff;

        return selected;
    }
}
