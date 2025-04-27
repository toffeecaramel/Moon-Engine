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

        testCombo = new ComboNumbers().init('moon-engine');
        add(testCombo);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.O)
        {
            testCombo.combo = FlxG.random.int(0, 999999999);
            testCombo.displayCombo(true);
            testCombo.screenCenter();
        }
    }
}