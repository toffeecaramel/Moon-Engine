package;

import sys.FileSystem;
import sys.io.File;

/**
 * A script which executes after the game is built.
 * Made by Funkin' Crew.
 */
class Postbuild
{
    static inline final BUILD_TIME_FILE:String = '.build_time';

    static function main():Void
    {
        printBuildTime();
    }

    static function printBuildTime():Void
    {
        // get buildEnd before fs operations since they are blocking
        var end:Float = Sys.time();
        if (FileSystem.exists(BUILD_TIME_FILE))
        {
            var fi:sys.io.FileInput = File.read(BUILD_TIME_FILE);
            var start:Float = fi.readDouble();
            fi.close();

            sys.FileSystem.deleteFile(BUILD_TIME_FILE);

            var buildTime:Float = roundToTwoDecimals(end - start);

            Sys.println('\n[ The game took $buildTime seconds to build! ]\n');
        }
    }

    static function roundToTwoDecimals(value:Float):Float
        return Math.round(value * 100) / 100;
}
