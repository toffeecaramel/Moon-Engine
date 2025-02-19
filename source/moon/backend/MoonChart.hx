package moon.backend;

using StringTools;

typedef NoteStruct =
{
    var time:Float;
    var data:Int;
    var lane:String;
    var type:String;
};

typedef EventStruct = 
{
    var tag:String;
    var values:Array<Dynamic>;
    var time:Float;
};

typedef MetadataStruct =
{
    var scrollSpd:Float;
    var stage:String;
    var p1:String;
    var p2:String;
    var spectators:Array<String>;
    var opponents:Array<String>;
};

typedef ChartStruct =
{
    var notes:Array<NoteStruct>;
    var events:Array<EventStruct>;
    var meta:MetadataStruct;
};

/**
 * Class used for handling ingame charts.
 * (Name pun not intended!)
 **/
class MoonChart
{
    public var content:ChartStruct;

    /**
     * Loads a chart from a path.
     * @param song        The song's name. (e.g. satin panties)
     * @param difficulty  The song's difficulty. (e.g. hard)
     * @param mix         The song's mix. (e.g. bf)
     */
    public function new(song:String, difficulty:String = 'hard', mix:String = 'bf')
    {
        content = Paths.JSON('$song/$mix/chart-$difficulty', 'songs');
    }

    public function convert()
    {
        
    }
}