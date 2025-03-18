package moon.dependency.scripting;

import flixel.group.FlxGroup;

class MoonEvent extends MoonScript
{
    public var time:Float;
    public var tag:String;
    public var values:Array<Dynamic> = [];
    
    public var PRESET_VARIABLES(default, set):Map<String, Dynamic>;

    public function new(tag:String, values:Array<Dynamic>)
    {
        super();
        this.tag = tag;
        this.values = values;

        load(Paths.data('events/$tag.hx'));
    }

    public function exec()
        get('onExecute')(values);

    @:noCompletion public function set_PRESET_VARIABLES(vars)
    {
        PRESET_VARIABLES = vars;

        for(variableName => variableValue in PRESET_VARIABLES)
            code.set(variableName, variableValue);

        return vars;
    }
}