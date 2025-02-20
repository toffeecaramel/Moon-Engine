package moon.toolkit;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;

using StringTools;
class ChartConvert extends FlxState
{
    private var _text:FlxText;
    private var _chartText:FlxText;

    private var state:String = 'formatSel';
    private var _curSelection:Int = 0;

    override public function create():Void
    {
        super.create();
        /*FlxG.stage.window.onDropFile.add((file) ->
            (!file.endsWith('.json')) ? trace('NO >:(') : MoonChart.convert('vslice', file, 'hard')
        );
        FlxG.stage.window.onDropFile.cancel();*/

        _text = new FlxText(0, 40, 0, 'Hello! Choose your chart format:');
        _text.setFormat(Paths.font('5by7_b.ttf'), 24, FlxColor.WHITE, CENTER);
        _text.screenCenter(X);
        add(_text);

        _chartText = new FlxText(0, 40, 0, '< None >');
        _chartText.setFormat(Paths.font('5by7_b.ttf'), 24, FlxColor.CYAN, CENTER);
        _chartText.screenCenter();
        add(_chartText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(state == 'formatSel')
        {
            if(FlxG.keys.justPressed.LEFT) changeSelection(1);
            else if (FlxG.keys.justPressed.RIGHT) changeSelection(-1);
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        _curSelection = FlxMath.wrap(_curSelection + change, 0, MoonChart.SUPPORTED_FORMATS.length - 1);
        _chartText.text = '< ${MoonChart.SUPPORTED_FORMATS[_curSelection]} >';
        _chartText.screenCenter();

    }

    private function changeTXT(txt:String, ?color:FlxColor = FlxColor.WHITE)
    {
        _text.text = txt;
        _text.color = color;
        _text.screenCenter(X);
    }
}