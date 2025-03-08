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

    /**
     * Loads up a script from a path.
     * @param path The path in which the script is at.
     */
    inline public function load(path:String)
    {
        if(FileSystem.exists(path))
            code = new Iris(File.getContent(path));
        else throw 'Script path at $path was not found!';
    }

    @:inheritDoc(crowplexus.iris.Iris.get)
    public function get(variable:String):Dynamic
        return (exists(variable)) ? code.get(variable) : null;

    @:inheritDoc(crowplexus.iris.Iris.set)
    public function set(variable:String, value:Dynamic)
        return code.set(variable, value);

    @:inheritDoc(crowplexus.iris.Iris.exists)
    public function exists(variable:String):Bool
        return code.exists(variable);

    @:inheritDoc(crowplexus.iris.Iris.call)
    public function call(func:String, ?args:Null<Array<Dynamic>>)
        return code.call(func, args);
}