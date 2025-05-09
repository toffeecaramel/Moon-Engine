package moon.game;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSubState;
import hxvlc.flixel.FlxVideoSprite;

class VideoPlayer extends FlxSubState
{
    var video:FlxVideoSprite;
    public function new(path:String, ?camera:FlxCamera)
    {
        super();
        this.camera = camera ?? FlxG.camera;

        video = new FlxVideoSprite(0, 0);
        video.antialiasing = true;
        video.load(Paths.mp4('darnellCutscene'));
        video.play();
        add(video);
    }
}