package moon.menus;

import flixel.util.FlxGradient;
import moon.menus.obj.settings.MusicPlayer;
import moon.game.submenus.PauseScreen;
import moon.game.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
    public static final textSharpness:Int = 200;
    //TODO: doccument thisssss
    public var isPlayState:Bool;
    var curSelected:Int = 0;
    var yPos:Float = 0;
    
    var optionFollower:FlxSprite;
    var navOptions:Array<OptionObject> = new Array<OptionObject>();
    var optionsContainer:FlxSpriteGroup = new FlxSpriteGroup();
    var optionDesc:FlxText;
    var bgm:MusicPlayer;

    public function new(isPlayState:Bool = false)
    {
        this.isPlayState = isPlayState;
        super();
        
        if(isPlayState)this.camera = PlayState.playgame.camALT;
        Paths.playSFX('configEnter', 'menus/settings');

        bgm = new MusicPlayer(1);
        add(bgm);

        var back = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLUE);
        back.blend = ADD;
        back.alpha = 0.0001;
        add(back);
        FlxTween.tween(back, {alpha: 0.5}, 1.8);
            
        var itsjoever = new FlxSprite().makeGraphic(FlxG.width + 15, FlxG.height, FlxColor.BLACK);
        itsjoever.screenCenter();
        itsjoever.scale.x = 0;
        itsjoever.alpha = 0.4;
        add(itsjoever);
        FlxTween.tween(itsjoever, {"scale.x": 1}, 1, {ease: FlxEase.circOut, startDelay: 0.2});

        optionFollower = new FlxSprite(0, 1000).makeGraphic(880, 30, 0xFF3850cd);
        add(optionFollower);
        optionFollower.screenCenter(X);
        FlxTween.tween(optionFollower, {alpha: 0.5}, 5, {type: PINGPONG, ease: FlxEase.quadIn});

        add(optionsContainer);

        var sttDisplay = new FlxText(0, yPos);
        sttDisplay.text = 'SETTINGS';
        sttDisplay.setFormat(Paths.font('vcr.ttf'), 48, CENTER);
        sttDisplay.screenCenter(X);
        sttDisplay.textField.antiAliasType = ADVANCED;
        sttDisplay.antialiasing = false;
        sttDisplay.textField.sharpness = textSharpness;
        optionsContainer.add(sttDisplay);
        yPos += sttDisplay.height + 15;

        for(i in 0...MoonSettings.categoryOrder.length)
            createCategory(MoonSettings.categoryOrder[i]);

        optionsContainer.y += 1000;
        
        var backGradient = FlxGradient.createGradientFlxSprite(FlxG.width + 10, FlxG.height + 10, 
        [0x00000000, 0x00000000, 0x00000000, 0xFF000000], 2, 90);
        backGradient.alpha = 0;
        add(backGradient);
        
        optionDesc = new FlxText();
        optionDesc.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.GRAY, RIGHT);
        optionDesc.text = '';
        optionDesc.textField.antiAliasType = ADVANCED;
        optionDesc.antialiasing = false;
        optionDesc.textField.sharpness = textSharpness;
        optionDesc.alpha = 0;
        add(optionDesc);
        optionDesc.y = (FlxG.height - optionDesc.height) - 12;
        
        for (obj in [backGradient, optionDesc])
            FlxTween.tween(obj, {alpha: 1}, 1);
        
        var info = new FlxText(-600);
        info.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.GRAY, LEFT);
        info.text = '[ESC] - Leave.\n[TAB] - Go to Next Category.';
        info.textField.antiAliasType = ADVANCED;
        info.antialiasing = false;
        info.textField.sharpness = textSharpness;
        add(info);
        
        info.y = (FlxG.height - info.height) - 12;
        FlxTween.tween(info, {x: 12}, 1, {ease: FlxEase.circOut});
        changeSelection(0);
    }

    public function createCategory(category:String):Void
    {
        final separation = 10;
        var categoryTxt:FlxText = new FlxText(190, yPos, -1, category);
        categoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.YELLOW, CENTER);
        categoryTxt.textField.antiAliasType = ADVANCED;
        categoryTxt.antialiasing = false;
        categoryTxt.textField.sharpness = textSharpness;
        optionsContainer.add(categoryTxt);

        final fixedEndX = 550 * 2;
        final sepStartX = categoryTxt.x + categoryTxt.width + separation;

        var categorySep = new FlxSprite(sepStartX, yPos + 15).makeGraphic(Std.int(fixedEndX - sepStartX), 8, FlxColor.YELLOW);
        optionsContainer.add(categorySep);
    
        yPos += categoryTxt.height + separation;
    
        final settings:Array<Setting> = MoonSettings.categories.get(category);
        for (i in 0...settings.length)
        {
            var option:OptionObject = new OptionObject(0, yPos, settings[i], category);
            option.screenCenter(X);
            optionsContainer.add(option);
            navOptions.push(option);
            yPos += option.height + separation;
        }
    
        yPos += separation;
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
        optionsContainer.y = FlxMath.lerp(optionsContainer.y, targetY, 0.17);
        optionFollower.y = FlxMath.lerp(optionFollower.y, cur.y, 0.4);

        //exit
        if(MoonInput.justPressed(BACK))
        {
            bgm.exit();
            Paths.playSFX('configExit', 'menus/settings');
            close();
            if(isPlayState) PlayState.playgame.openSubState(new PauseScreen(PlayState.playgame.camALT));
        }
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, navOptions.length - 1);
        Paths.playSFX('configScroll', 'menus/settings');

        optionDesc.text = navOptions[curSelected].setting.description;
        optionDesc.x = (FlxG.width - optionDesc.width) - 12;

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
