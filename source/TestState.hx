package;

import haxe.ui.ComponentBuilder;
import flixel.FlxG;
import flixel.FlxState;
import haxe.ui.components.Button;

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