package;

import sys.io.File;

/**
 * A script which executes before the game is built.
 * Originally Made by Funkin' Crew.
 */
class Prebuild
{
    static inline final BUILD_TIME_FILE:String = '.build_time';

    /**
     * Just a few messages to keep your motivation up!
     * Don't ever give up on coding, it is hard! but with dedication, you'll get where you want <3
     * some of these are so silly lol
    **/
    
    public static var motivationMsgs:Array<String> = [
        "Don't give up hope, no matter what people say.",
		"I know you can make it better than it ever was.",
        "Hmm...",
        "I sure do love waiting!",
        "Some burguers would be nice rn...",
        "Chicken nuggiess,,.,",
        "Deltarune Tomorrow",
        "(Did you know?) Spirits face was inspired by Tom Fulps face. (found this on reddit lolol)",
        "A mimir...",
        "Mano Mix is cool",
        "Luna Mix is cool",
        "Oh, Okay! let's go!",
        "Don't forget to drink some water!",
        "You're almost there!",
        "Why do we brainstorm with ideas only when we're not working?"
    ];

    static function main():Void
    {
        saveBuildTime();
        traceMessage();
    }

    public static function traceMessage():Void
    {
        final message = motivationMsgs[Std.random(motivationMsgs.length)];
        Sys.println('\x1b[36m[INFO] Today\'s message: $message\x1b[0m');
    }

    static function saveBuildTime():Void
    {
        var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
        var now:Float = Sys.time();
        fo.writeDouble(now);
        fo.close();
    }
}
