package moon.dependency.scripting;

import flixel.group.FlxGroup;

/**
 * A class for handling in-game events.
 */
class MoonEvent extends MoonScript
{
    /**
     * The event's time in milliseconds.
     */
    public var time:Float;

    /**
     * The event's tag.
     */
    public var tag:String;

    /**
     * The event's values.
     */
    public var values:Dynamic;
    
    /**
     * Variables map for the script.
     */
    public var PRESET_VARIABLES(default, set):Map<String, Dynamic>;

    /**
     * A list of hardcoded events (by tag) that won't be handled from a script, but by code instead.
     */
    public var HARDCODED_EVENTS:Array<String> = ['SetCameraFocus', 'SetCameraZoom', 'ChangeBPM'];

    /**
     * Whenever the event is valid as a script.
     * If false, it won't be readed as a script file.
     */
    public var valid:Bool = true;
    public function new(tag:String, values:Dynamic)
    {
        super();

        this.tag = tag;
        this.values = values;

        (!HARDCODED_EVENTS.contains(tag) && Paths.exists('data/events/$tag.hx')) ? load('data/events/$tag.hx') : valid = false;
    }

    public function exec()
        if(valid) call('onExecute', [values]);

    public function getCamFocusValues(charFocus:String, duration:Float, ease:String)
    {
        this.tag = 'SetCameraFocus';

        this.values = {
            character: charFocus,
            duration: duration,
            ease: ease
        };
        
        this.time = 0;
        return this;
    }

    public function getCamZoomValues(zoom:Float, duration:Float, ease:String)
    {
        this.tag = 'SetCameraZoom';

        this.values = {
            zoom: zoom,
            duration: duration,
            ease: ease,
            mode: 'stage'
        };

        this.time = 0;
        return this;
    }

    @:noCompletion public function set_PRESET_VARIABLES(vars)
    {
        PRESET_VARIABLES = vars;

        if(valid)
            for(variableName => variableValue in PRESET_VARIABLES)
                code.set(variableName, variableValue);

        return vars;
    }
}