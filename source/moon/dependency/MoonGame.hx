package moon.dependency;

import moon.global_obj.GlobalMusic;
import moon.global_obj.Alphabet;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxGame;

class MoonGame extends FlxGame
{
    override public function new(?gameWidth:Int, ?gameHeight:Int, 
        ?initialState:Null<flixel.util.typeLimit.NextState.InitialState>, ?updateFramerate:Int, ?drawFramerate:Int, 
        ?skipSplash:Bool, ?startFullscreen:Bool)
    {
        super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);

        GlobalMusic.init();
		MoonSettings.init();
        Alphabet.init();

        FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) ->
		{
            final kc = e.keyCode;
			// prevents keyboard presses when going on fullscreen
            // got from FE, by crowplexus and nebulazorua
			if (kc == FlxKey.ENTER && e.altKey)
				e.stopImmediatePropagation();

            // update volume settings when the volume is changed.
            if((kc == FlxKey.PLUS || kc == FlxKey.NUMPADPLUS) || (kc == FlxKey.MINUS || kc == FlxKey.NUMPADMINUS))
                MoonSettings.setSetting("Master Volume", FlxG.sound.volume * 100);
		}, false, 100);
    }
}