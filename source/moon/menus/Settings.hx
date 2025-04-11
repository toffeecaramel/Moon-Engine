package moon.menus;

import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import moon.menus.obj.settings.OptionObject;
import moon.dependency.user.MoonSettings;
import moon.dependency.user.MoonSettings.Setting;

class Settings extends FlxSubState
{
    //TODO: doccument thisssss
    public var isPlayState:Bool;

    var navOptions:Array<OptionObject> = new Array<OptionObject>();
    var optionsContainer:FlxSpriteGroup = new FlxSpriteGroup();
    var curSelected:Int = 0;
    
    public function new(isPlayState:Bool = false)
    {
        this.isPlayState = isPlayState;
        super();

        add(optionsContainer);

        for(i in 0...MoonSettings.categoryOrder.length)
            createCategory(MoonSettings.categoryOrder[i]);

        changeSelection(0);
    }

    var yPos:Float = 0;
    public function createCategory(category:String):Void
    {
        var categoryTxt = new FlxText(0, yPos, FlxG.width, category);
        categoryTxt.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.YELLOW, CENTER);
        categoryTxt.text = category;
        categoryTxt.screenCenter(X);
        optionsContainer.add(categoryTxt);

        var categorySep = new FlxSprite(0, yPos + categoryTxt.height + 5).makeGraphic(FlxG.width, 4, FlxColor.YELLOW);
        categorySep.screenCenter(X);
        optionsContainer.add(categorySep);

        yPos += categoryTxt.height + categorySep.height + 20;

        final settings:Array<Setting> = MoonSettings.categories.get(category);
        for (i in 0...settings.length)
        {
            var option:OptionObject = new OptionObject(0, yPos, settings[i], category);
            option.screenCenter(X);
            optionsContainer.add(option);
            navOptions.push(option);
            yPos += option.height + 10;
        }

        yPos += 10;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // change selection
        if(MoonInput.justPressed(UI_UP)) changeSelection(-1);
        else if(MoonInput.justPressed(UI_DOWN)) changeSelection(1);
        else if (FlxG.keys.justPressed.TAB) changeCategory();
        if (FlxG.mouse.wheel != 0)
            changeSelection(-FlxG.mouse.wheel);

        // center current selected option
        final cur = navOptions[curSelected];
        final targetY:Float = FlxG.height / 2 - (cur.y + cur.height / 2 - optionsContainer.y);
        optionsContainer.y = FlxMath.lerp(optionsContainer.y, targetY, 0.26);
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, navOptions.length - 1);

        for (i in 0...navOptions.length)
            navOptions[i].selected = (i == curSelected);
    }

    private function changeCategory():Void
    {
        final curCat = navOptions[curSelected].category;
        final curIndex = MoonSettings.categoryOrder.indexOf(curCat);
        final nextCat = (curIndex + 1) % MoonSettings.categoryOrder.length;

        for (i in 0...navOptions.length)
        {
            if (navOptions[i].category == MoonSettings.categoryOrder[nextCat])
            {
                curSelected = i;
                changeSelection(0);
                return;
            }
        }
    }
}
