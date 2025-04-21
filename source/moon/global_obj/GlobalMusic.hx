package moon.global_obj;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

@:publicFields

/**
 * A class for playing songs globally, mostly menu music.
 */
class GlobalMusic
{
    static var song(default, set):String;

    static var sound:MoonSound;

    /**
     * Initiates the class. Necessary for everything to work.
     */
    static function init()
    {
        sound = new MoonSound();
        FlxG.sound.list.add(sound);
    }

    static function update()
    {
        if(song != null && sound.metadata != null) Conductor.time = sound.time;
    }

    /**
     * Starts a song upon calling, does nothing if already playing.
     * @param fade Whether or not should the song fade in.
     */
    static function start(fade:Bool = false)
    {
        if (sound != null && !sound.playing)
        {
            sound.volume = (fade) ? 0 : MoonSettings.callSetting('Music Volume');
            sound.play();
            if (fade) sound.fadeIn(4, 0, MoonSettings.callSetting('Music Volume'));
        }
    }

    @:noCompletion static function set_song(songi:String):String
    {
        if(song != songi)
        {
            song = songi;
            if(sound != null)
            {
                (sound.playing) ? sound.stop() : null;
                sound.loadEmbedded(Paths.sound(songi));
                sound.stop();
                sound.metadata = (Paths.fileExists('$songi-metadata.json', TEXT)) ? Paths.JSON('$songi-metadata') : null;

                if(sound.metadata != null)
                {
                    Conductor.bpm = sound.metadata.bpm ?? 0;
                    Conductor.timeSignature = TimeSignature.fromString('${sound.metadata.timeSignature[0] ?? 0}/${sound.metadata.timeSignature[1] ?? 0}');
                    sound.looped = sound.metadata.looped;
                }
            }
            else trace('Global Song is null. To fix, call init() before changing the song.', "WARNING");
        }
        return song;
    }

    static function destroy()
    {
        FlxG.sound.list.remove(sound);
        sound.destroy();
    }
}