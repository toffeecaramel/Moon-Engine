package moon.dependency;

import moon.dependency.scripting.MoonEvent;
import haxe.Json;
#if sys
import moonchart.formats.fnf.legacy.FNFPsych;
import moonchart.formats.fnf.FNFCodename;
import moonchart.formats.fnf.FNFVSlice;
#end
using StringTools;

/**
 * Structure for MoonChart's notes.
 */
typedef NoteStruct =
{
    var time:Float;
    var data:Int;
    var lane:String;
    var type:String;
    var duration:Float;
};

/**
 * Structure for MoonChart's events.
 */
typedef EventStruct = 
{
    var tag:String;
    var values:Dynamic;
    var time:Float;
};

/**
 * Structure for MoonChart's metadata.
 */
typedef MetadataStruct =
{
    // Game data
    var bpm:Float;
    var scrollSpd:Float;
    var stage:String;
    var players:Array<String>;
    var spectators:Array<String>;
    var opponents:Array<String>;

    // Other data
    var displayName:String;
    var album:String;
    var artist:String;
    var charter:String;
    var diffRating:Int;
    var preview:Array<Float>;
    
    // MISC
    var generatedBy:String;
    var version:String;
};

/**
 * Structure for the entire MoonChart.
 */
typedef ChartStruct =
{
    var meta:MetadataStruct;
    var notes:Array<NoteStruct>;
};

/**
 * Class used for handling ingame charts.
 * (Name pun not intended!)
 **/
class MoonChart
{
    /**
     * All the chart formats supported for converting.
     */
    public static final SUPPORTED_FORMATS:Array<String> = 
    [
        //TODO: add other formats in here.
        'legacy',
        'psych',
        'codename',
        'v-slice'
    ];

    /**
     * All of the chart content, except for the events.
     */
    public var content:ChartStruct;

    /**
     * All of the chart's events.
     */
    public var events:Array<EventStruct>;

    /**
     * Loads a chart from a path.
     * @param song        The song's name. (e.g. satin panties)
     * @param difficulty  The song's difficulty. (e.g. hard)
     * @param mix         The song's mix. (e.g. bf)
     */
    public function new(song:String, difficulty:String = 'hard', mix:String = 'bf')
    {
        final modifier = (difficulty == 'erect' || difficulty == 'nightmare') ? '-erect' : '';
        events = (Paths.fileExists('assets/songs/$song/$mix/events$modifier.json')) ? Paths.JSON('$song/$mix/events$modifier', 'songs') : [];
        content = Paths.JSON('$song/$mix/chart-$difficulty', 'songs');
    }

    /**
     * Converts a chart type to Moon Engine's chart type.
     * @param type The chart type you're converting from
     * @param path The chart's path
     * @param difficulty The chart's difficulty
     */
    public static function convert(type:String, path:String, difficulty:String, ?meta)
    {
        // gotta do that since moonchart uses filesystem.
        #if sys
        // So first, we'll get the chart format and convert 'em to
        // vslice, because vslice will be our main 'base' for converting.
        // (thanks moonchart for existing its BASED AF)
        final chart = switch (type)
        {
            // This switch is a mess btw!!!
            case 'psych':
                final psy = new FNFPsych().fromFile(path, null, difficulty);
                new FNFVSlice().fromFormat(psy);
            case 'codename': 
                final code = new FNFCodename().fromFile(path, meta, difficulty);
                new FNFVSlice().fromFormat(code);
            default: new FNFVSlice().fromFile(path, meta, difficulty);
        };

        final data = Json.parse(chart.stringify().data);
        final metadata = Json.parse(chart.stringify().meta);

        // Now we create a variable for the converted chart.
        var convertedChart:ChartStruct = {notes: [], meta: null};
        var convertedEvents:Array<EventStruct> = [];

        // Now we convert the notes and add them to the chart.
        if (Reflect.hasField(data.notes, difficulty))
        {
            final noteArray:Array<Dynamic> = Reflect.field(data.notes, difficulty);
            
            for (note in noteArray)
            {
                final note:NoteStruct =
                {
                    time: note.t,
                    data: (note.d > 3) ? Std.int(note.d - 4) : note.d,
                    lane:  (note.d > 3) ? 'opponent' : 'p1',
                    type: (note.k == '') ? null : note.k,
                    duration: note.l
                };
                convertedChart.notes.push(note);
            }
        }

        // time to convert some basic events (such as camera and stuff)
        final events:Array<Dynamic> = data.events;
        for(event in events)
        {
            switch(event.e)
            {
                case 'FocusCamera':
                    final camVent:EventStruct = //mogus
                    {
                        tag: 'SetCameraFocus',
                        values: {
                            character: (event.v.char == 1) ? 'opponent' : 'player', 
                            duration: (event.v.ease == 'CLASSIC') ? 26 : event.v.duration,
                            ease: (event.v.ease == 'CLASSIC') ? 'expoOut' : event.v.ease,
                            x: event.v.x ?? 0,
                            y: event.v.y ?? 0
                        },
                        time: event.t
                    };
                convertedEvents.push(camVent);

                case 'ZoomCamera':
                    final camZoomVent:EventStruct = {
                        tag: 'SetCameraZoom',
                        values: {
                            zoom: event.v.zoom,
                            duration: event.v.duration,
                            ease: event.v.ease
                        },
                        time: event.t                    
                    };
                convertedEvents.push(camZoomVent);
            }
        }

        // Now let's convert the metadata as well.
        convertedChart.meta =
        {
            bpm: metadata.timeChanges[0].bpm,
            scrollSpd: Reflect.field(data.scrollSpeed, difficulty),
            stage: metadata.playData.stage,
            players: [metadata.playData.characters.player],
            spectators: [metadata.playData.characters.girlfriend],
            opponents: [metadata.playData.characters.opponent],

            displayName: metadata.songName,
            album: metadata.playData.album,
            artist: metadata.artist,
            charter: metadata.charter,
            diffRating: Reflect.field(metadata.playData.ratings, difficulty),
            preview: [metadata.playData.previewStart, metadata.playData.previewEnd],

            generatedBy: metadata.generatedBy,
            version: metadata.version
        };

        Paths.saveFileContent('assets/data/chart-converter/mychart-$difficulty-converted.json', Json.stringify(convertedChart, "\t"));
        Paths.saveFileContent('assets/data/chart-converter/mychart_events-$difficulty-converted.json', Json.stringify(convertedEvents, "\t"));
        #else
        throw 'Chart conversion is currently only available for Desktop.';
        #end
    }
}