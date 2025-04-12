package moon.dependency;

import flixel.FlxG;
import flixel.FlxGame;

class MoonGame extends FlxGame
{
    override public function new(?gameWidth:Int, ?gameHeight:Int, 
        ?initialState:Null<flixel.util.typeLimit.NextState.InitialState>, ?updateFramerate:Int, ?drawFramerate:Int, 
        ?skipSplash:Bool, ?startFullscreen:Bool)
    {
        super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);

        //Init settings
		MoonSettings.init();
    }
}