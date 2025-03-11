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
		"I know you can make it better than it ever was."
    ];

    static function main():Void
    {
        saveBuildTime();
        traceMessage();
    }

    public static function traceMessage():Void
    {
        final message = motivationMsgs[Std.random(motivationMsgs.length)];
        Sys.println('\n[ $message ]' + "\n\n[ Anyways, the game is buildin' up just now. ]\n[ Please wait... :3 ]\n");
    }

    static function saveBuildTime():Void
    {
        var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
        var now:Float = Sys.time();
        fo.writeDouble(now);
        fo.close();
    }
}
