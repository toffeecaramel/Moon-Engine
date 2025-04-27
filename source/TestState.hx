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

        testCombo = new ComboNumbers(50, 50).init('moon-engine');
        add(testCombo);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.O)
        {
            testCombo.combo++;
            testCombo.displayCombo(true);
        }

        if(FlxG.keys.justPressed.P)
        {
            testCombo.comboRoll(0, 2, true);
        }
    }
}