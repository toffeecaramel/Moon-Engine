// in PlayField.hx
package moon.game.obj;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import moon.backend.gameplay.InputHandler;
import flixel.FlxG;
import flixel.group.FlxGroup;

import moon.game.obj.notes.*;
import moon.backend.gameplay.Timings;

@:publicFields
class PlayField extends FlxGroup
{
    public static var playfield:PlayField;
    var conductor:Conductor;
    var playback:Song;

    public var noteSpawner:NoteSpawner;
    var chart:MoonChart;

    var song:String;
    var mix:String;
    var difficulty:String;

    public var strumlines:Array<Strumline> = [];
    public var inputHandlers:Array<InputHandler> = [];

    var tst:FlxText;

    /**
     * Creates a gameplay scene on screen.
     * @param song        The song that'll be played on the directory.
     * @param difficulty  The song's difficulty.
     * @param mix         The song's mix (e.g. bf, pico)
     */
    public function new(song:String, difficulty:String, mix:String)
    {
        super();
        this.song = song;
        this.mix = mix;
        this.difficulty = difficulty;

        playfield = this;

        //< -- SONG SETUP -- >//
        chart = new MoonChart(song, difficulty, mix);
        
        conductor = new Conductor(chart.content.meta.bpm, 4, 4);
        conductor.onBeat.add(beatHit);
        
        playback = new Song(
        [{name: song, mix: mix, type: Inst},
        {name: song, mix: mix, type: Voices_Opponent},
        {name: song, mix: mix, type: Voices_Player}],
        conductor);
    
        //< -- STRUMLINES & INPUTS SETUP -- >//
        strumlines = [];
        inputHandlers = [];

        // strums positioning values
        final xVal = (FlxG.width * 0.5);
        final xAddition = (FlxG.width * 0.25);
        final strumXs:Array<Float> = [-xAddition, xAddition];

        // some setups for their ids
        final playerIDs:Array<String> = ["opponent", "p1"];
        final isCPUPlayers:Array<Bool> = [true, false];

        // actually setup strumlines
        for (i in 0...playerIDs.length)
        {
            var strumline = new Strumline(xVal + strumXs[i], 80, 'v-slice', isCPUPlayers[i], playerIDs[i], conductor);
            add(strumline);
            strumlines.push(strumline);

            var inputHandler = new InputHandler(null, playerIDs[i], strumline, conductor);
            inputHandlers.push(inputHandler);

            // specific thing when its player 1 only
            // oh btw lemme
            // TODO: ADD p2 support here and... mhmhmhm AGFAGH BARK :3
            if (playerIDs[i] == 'p1')
            {
                inputHandlers[i].onNoteHit = function(note, timing, isSustain)
                {
                    tst.text = 'SCORE: ${inputHandlers[i].stats.score} // MISSES: ${inputHandlers[i].stats.misses} // ACCURACY: ${inputHandlers[i].stats.accuracy}%';
                    tst.screenCenter(X);
                };

                inputHandlers[i].onNoteMiss = function(note:Note){
                    tst.text = 'SCORE: ${inputHandlers[i].stats.score} // MISSES: ${inputHandlers[i].stats.misses} // ACCURACY: ${inputHandlers[i].stats.accuracy}%';
                    tst.screenCenter(X);
                };
            }
        }

        // little text for testing out the accuracy;
        tst = new FlxText(0, 20);
        tst.text = ':3';
        tst.setFormat(Paths.font('phantomuff/full.ttf'), 32, FlxColor.WHITE, LEFT);
        add(tst);

        //< -- NOTES SETUP -- >//

        // add the note spawner
        noteSpawner = new NoteSpawner(chart.content.notes, strumlines, conductor);
        noteSpawner.scrollSpeed = chart.content.meta.scrollSpd;
        add(noteSpawner);

        // set input handler's notes
        for (inputHandler in inputHandlers)
            inputHandler.thisNotes = noteSpawner.notes;

        // set the song's state
		playback.state = PLAY;
    }

    override public function update(dt:Float)
    {
        conductor.time += dt * 1000;

        // this is kinda... dumb? so uh
        //TODO: shorten this? somehow??
        inputHandlers[1].justPressed = [MoonInput.justPressed(LEFT),MoonInput.justPressed(DOWN),MoonInput.justPressed(UP),MoonInput.justPressed(RIGHT),
		];

		inputHandlers[1].pressed = [MoonInput.pressed(LEFT),MoonInput.pressed(DOWN),MoonInput.pressed(UP),MoonInput.pressed(RIGHT),
		];

		inputHandlers[1].released = [MoonInput.released(LEFT),MoonInput.released(DOWN),MoonInput.released(UP),MoonInput.released(RIGHT),
		];

        super.update(dt);
        for (inputHandler in inputHandlers)
            inputHandler.update();
    }

    function beatHit(beat:Float)
    {

    }
}