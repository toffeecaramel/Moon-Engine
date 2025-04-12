package moon.menus.obj.settings;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class MusicPlayer extends FlxTypedGroup<FlxBasic>
{
    public var music:MoonSound = new MoonSound();
    public var metadata:Dynamic;

    public var twnActive:Bool = false;

    public function new(index:Int = 1)
    {
        super();

        music.loadEmbedded(Paths.sound('menus/settings/configMenu$index', "music"), true);
        music.play();
        FlxG.sound.list.add(music);
        metadata = Paths.JSON('menus/settings/configMenu$index-metadata', "music");

        music.volume = 0;

        //TODO: add a display to show the song metadata
        //sorta like the trace does.
        trace('Now Playing: ${metadata.author} - ${metadata.songName}');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        if(!twnActive) music.volume = FlxMath.lerp(music.volume, MoonSettings.callSetting('Music Volume'), 0.01);
    }

    public function exit()
    {
        twnActive = true;
        FlxTween.tween(music, {volume: 0}, 0.7, {onComplete: (_) -> music.destroy()});
    }
}