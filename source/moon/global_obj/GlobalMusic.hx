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
    static var metadata:Metadata;
    static var song(default, set):String;
    static var sound:MoonSound;
    static var conductor:Conductor;

    /**
     * Initiates the class. Necessary for everything to work.
     */
    static function init()
    {
        sound = new MoonSound();
        conductor = new Conductor();
        FlxG.sound.list.add(sound);
    }

    static function update()
    {
        if(FlxG.sound.music != null && conductor != null) conductor.time = FlxG.sound.music.time;
    }

    /**
     * Starts a song upon calling, does nothing if already playing.
     * @param fade Whether or not should the song fade in.
     */
    static function start(fade:Bool = false)
    {
        if (sound != null && !sound.playing)
        {
            FlxG.sound.playMusic(Paths.sound(song), (fade) ? 0 : MoonSettings.callSetting('Music Volume'), true);
            if (fade) FlxG.sound.music.fadeIn(4, 0, MoonSettings.callSetting('Music Volume'));

            if(sound.metadata != null)
            {
                conductor.reset();
                conductor.changeBpmAt(0, sound.metadata.bpm ?? 0, sound.metadata.timeSignature[0] ?? 0, sound.metadata.timeSignature[1] ?? 0);
                FlxG.sound.music.looped = sound.metadata.looped;
            }
        }
    }

    @:noCompletion static function set_song(songi:String):String
    {
        if(song != songi)
        {
            song = songi;
            metadata = (Paths.fileExists('$songi-metadata.json', TEXT)) ? Paths.JSON('$songi-metadata') : null;
        }
        return song;
    }

    static function destroy()
    {
        FlxG.sound.list.remove(sound);
        sound.destroy();
        conductor = null;
    }
}