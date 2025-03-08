package moon.dependency.scripting;

import sys.FileSystem;
import sys.io.File;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;

/**
 * Class meant to handle scripts.
 */
class MoonScript
{
    /**
     * The script content itself.
     */
    public var code:Iris;

    /**
     * Just some default variables that'll be set on upon initializng the script.
     */
    public var DEFAULT_VARIABLES:Map<String, Dynamic> = [
        "Paths" => Paths,
        "Constants" => Constants,
        "MoonSprite" => MoonSprite
    ];

    public function new(){}

    /**
     * Loads up a script from a path.
     * @param path The path in which the script is at.
     */
    inline public function load(path:String)
    {
        if(FileSystem.exists(path))
        {
            code = new Iris(File.getContent(path));
            for(variableName => variableValue in DEFAULT_VARIABLES)
                code.set(variableName, variableValue);
        }
        else throw 'Script path at $path was not found!';
    }

    @:inheritDoc(crowplexus.iris.Iris.get)
    public function get(variable:String):Dynamic
        return (exists(variable)) ? code.get(variable) : null;

    @:inheritDoc(crowplexus.iris.Iris.set)
    public function set(variable:String, value:Dynamic, ?allowOverride:Bool = true)
        return code.set(variable, value, allowOverride);

    @:inheritDoc(crowplexus.iris.Iris.exists)
    public function exists(variable:String):Bool
        return code.exists(variable);

    @:inheritDoc(crowplexus.iris.Iris.call)
    public function call(func:String, ?args:Null<Array<Dynamic>>)
        return return (exists(func)) ? code.call(func, args) : null;
}