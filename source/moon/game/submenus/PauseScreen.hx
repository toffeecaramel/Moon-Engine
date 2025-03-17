package moon.game.submenus;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSubState;

class PauseScreen extends FlxSubState
{
    private var itemList:Array<Array<String>> = [
        ['Resume', 'Will unpause the game.'],
        ['Restart Song', 'Will make you return from the song\'s beginning.'],
        ['Settings', 'Will open a sub menu for settings (it won\'t restart the song.)']
    ];

    public function new(camera:FlxCamera)
    {
        super();
        this.camera = camera;

        var back = new MoonSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        back.alpha = 0.0001;
        add(back);
        FlxTween.tween(back, {alpha: 0.5}, 0.4);
    }
}