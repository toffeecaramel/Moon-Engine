package;

import moon.game.obj.judgements.ComboNumbers;
import haxe.ui.ComponentBuilder;
import flixel.FlxG;
import flixel.FlxState;
import haxe.ui.components.Button;

class TestState extends FlxState
{
    var testCombo:ComboNumbers;
    override public function create():Void
    {
        super.create();
        FlxG.mouse.useSystemCursor = true;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}