package;

import haxe.ui.ComponentBuilder;
import flixel.FlxG;
import haxe.ui.macros.ComponentMacros;
import flixel.FlxState;

class TestState extends FlxState
{
    override public function create():Void
    {
        super.create();
        FlxG.mouse.useSystemCursor = true;
        add(ComponentBuilder.fromFile("assets/data/ui/test.xml"));
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}