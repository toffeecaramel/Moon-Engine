package moon.global_obj;

import moon.dependency.MoonSound.Metadata;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

@:publicFields

/**
 * A class for playing songs globally, mostly menu music.
 */
class GlobalMusic
{
    /**
     * Starts a song upon calling, does nothing if already playing.
     * @param song The song's path.
     * @param fade Whether or not should the song fade in.
     */
    static function start(song:String, fade:Bool = false)
    {
        if ((FlxG.sound.music != null && !FlxG.sound.music.playing ) || (FlxG.sound.music == null))
        {
            FlxG.sound.playMusic(Paths.sound(song), (fade) ? 0 : MoonSettings.callSetting('Music Volume'), true);
            if (fade) FlxG.sound.music.fadeIn(140, 0, MoonSettings.callSetting('Music Volume'));
        }
    }
}