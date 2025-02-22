package moon.dependency.scripting;

import sys.FileSystem;
import flixel.FlxState;
import sys.io.File;
import hscript.Parser;
import hscript.Expr;
import hscript.Interp;

/**
 * Class meant to handle script loading with Hscript Improved. (which is made by Codename Crew)
 */
class MoonScript
{
    private var interp:Interp;

    public function new()
    {
        interp = new Interp(); // literally just that lol
    }

    inline public function load(path:String)
    {
        if(FileSystem.exists(path))
        {
            var parser = new Parser();
            var expr = parser.parseString(File.getContent(path));
            interp.execute(expr);
        }
        else trace('Script path at $path was not found!', "ERROR");
    }

    public function get(str:String):Dynamic
        return (exists(str)) ? interp.variables.get(str) : null;

    public function set(str:String, value:Dynamic)
        interp.variables.set(str, value);

    public function exists(str:String):Bool
        return interp.variables.exists(str);
}