package moon.dependency;
using StringTools;
/**
 * A class meant for utilities, there's a buncha cool helpful stuff here :3
 */
class MoonUtils
{
    /**
     * Returns a integer number to a arrow direction.
     * @param int The number in which will be used for getting the direction.
     */
    inline public static function intToDir(int:Int)
    {
        // Repeat 2 times 'cause theres 4 more, usually for opponent.
        final directions = ['left', 'down', 'up', 'right', 'left', 'down', 'up', 'right'];
        return directions[int];
    }

    
    public static function getArrayFromFile(path:String)
    {
        if (Paths.fileExists(path))
            return Paths.getFileContent(path).split("\n").map((line) -> return line.trim());
        else 
            trace('File at $path not found!', "ERROR");
        return null;
    }
}