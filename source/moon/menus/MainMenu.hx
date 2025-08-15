package moon.menus;

import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxState;

class MainMenu extends FlxState
{
    //! THIS MENU IS A PLACEHOLDER. TODO. YEAH. I HATE MY LIFE.
    var opt:Array<String> = ['story mode', 'freeplay', 'settings', 'character select', 'fuck off'];

    var texts:Array<FlxText> = []; //not a group because its a fucking placeholder
    // why the fuck am I saying fuck so many fucking times
    // someone fucking help me

    // no but really, this menu is awful
    // (because its a placeholder)

    var curSelected:Int = 0;
    override public function create()
    {
        super.create();

        var yPos = 0.0;
        for (i in 0...opt.length)
        {
            var text = new FlxText(0, yPos, 900, opt[i], 32);
            text.font = Paths.font('vcr.ttf');
            texts.push(text);
            text.screenCenter(X);
            add(text);
            yPos += text.height;
        }

        changeSelection(0);
    }

    override public function update(elapsed) {
        super.update(elapsed);
        if(MoonInput.justPressed(UI_DOWN)) changeSelection(1);
        if(MoonInput.justPressed(UI_UP)) changeSelection(-1);
        
        if(MoonInput.justPressed(ACCEPT))
        {
            switch(opt[curSelected])
            {
                case 'story mode': return; // nothing for now.
                case 'freeplay': openSubState(new Freeplay('bf')); //TODO
                case 'settings': openSubState(new Settings(false));
                case 'fuck off': #if system Sys.exit(1); #end
            }
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, opt.length - 1);
        Paths.playSFX('ui/scrollMenu');

        for(i in 0...texts.length)
        {
            texts[i].color = (i == curSelected) ? FlxColor.CYAN : FlxColor.WHITE;
            texts[i].text = (i == curSelected) ? '${opt[i]} < (you)' : opt[i];
        }
    }
}