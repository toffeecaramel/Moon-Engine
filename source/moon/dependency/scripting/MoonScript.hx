package moon.dependency.scripting;

import sys.FileSystem;
import sys.io.File;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;

/**
 * Class meant to handle script loading with Hscript Improved. (which is made by Codename Crew)
 */
class MoonScript
{
    public var code:Iris;
    public function new(){}

    inline public function load(path:String)
    {
        if(FileSystem.exists(path))
            code = new Iris(File.getContent(path));
        else trace('Script path at $path was not found!', "ERROR");
    }

    public function get(variable:String):Dynamic
        return (exists(variable)) ? code.get(variable) : null;

    public function set(variable:String, value:Dynamic)
        return code.set(variable, value);

    public function exists(variable:String):Bool
        return code.exists(variable);
}