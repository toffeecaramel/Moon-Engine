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

    var playerStrumline:Strumline;
    var opponentStrumline:Strumline;
    var noteSpawner:NoteSpawner;
    var chart:MoonChart;

    var song:String;
    var mix:String;
    var difficulty:String;

    var strumlines:Array<Strumline> = [];

    public var inputHandlerP1:InputHandler;


    var tst:FlxText;
    public function new(song:String, difficulty:String, mix:String)
    {
        super();
        this.song = song;
        this.mix = mix;
        this.difficulty = difficulty;

        playfield = this;

        //< -- SONG SETUP -- >//

        conductor = new Conductor(182, 4, 4);
		conductor.onBeat.add(beatHit);

        playback = new Song(
			[{name: song, mix: mix, type: Inst},
			{name: song, mix: mix, type: Voices_Opponent},
			{name: song, mix: mix, type: Voices_Player}],
        conductor);

        chart = new MoonChart(song, difficulty, mix);

        //< -- STRUMLINES SETUP -- >//

        final xVal = (FlxG.width * 0.5);
        final xAddition = (FlxG.width * 0.25);

        opponentStrumline = new Strumline(xVal - xAddition, 80, 'v-slice', true, "opponent", conductor);
        add(opponentStrumline);
        strumlines.push(opponentStrumline);

        playerStrumline = new Strumline(xVal + xAddition, 80, 'v-slice', false, "p1", conductor);
        add(playerStrumline);
        strumlines.push(playerStrumline);

        tst = new FlxText();
        tst.text = ':3';
        tst.setFormat(Paths.font('phantomuff/full.ttf'), 32, FlxColor.WHITE, LEFT);
        add(tst);

        //< -- NOTES SETUP -- >//

        noteSpawner = new NoteSpawner(chart.content.notes, strumlines, conductor);
        add(noteSpawner);

        //< -- INPUTS SETUP -- >//

        inputHandlerP1 = new InputHandler(noteSpawner.notes, 'p1', conductor);
        inputHandlerP1.onNoteHit = function(note, timing, isSustain)
        {
            playerStrumline.receptors.members[note.direction].onNoteHit(timing);
            tst.text = inputHandlerP1.stats.accuracy + '%';
            tst.setPosition(playerStrumline.x, 20);
        };

        inputHandlerP1.onNoteMiss = function(note:Note){
            tst.text = inputHandlerP1.stats.accuracy + '%';
            tst.setPosition(playerStrumline.x, 20);
        };
        inputHandlerP1.onGhostTap = function(dir:Int)
        {
            playerStrumline.receptors.members[dir].strumNote.playAnim('${MoonUtils.intToDir(dir)}-press', true);
        };
        inputHandlerP1.onKeyRelease = function(dir:Int)
        {
            playerStrumline.receptors.members[dir].strumNote.playAnim('${MoonUtils.intToDir(dir)}-static', true);
        };

		playback.state = PLAY;
    }

    override public function update(dt:Float)
    {
        conductor.time += dt * 1000;

        inputHandlerP1.justPressed = [MoonInput.justPressed(LEFT),MoonInput.justPressed(DOWN),MoonInput.justPressed(UP),MoonInput.justPressed(RIGHT),
		];

		inputHandlerP1.pressed = [MoonInput.pressed(LEFT),MoonInput.pressed(DOWN),MoonInput.pressed(UP),MoonInput.pressed(RIGHT),
		];

		inputHandlerP1.released = [MoonInput.released(LEFT),MoonInput.released(DOWN),MoonInput.released(UP),MoonInput.released(RIGHT),
		];

        inputHandlerP1.thisNotes = noteSpawner.notes;

        super.update(dt);
        inputHandlerP1.update();
    }

    function beatHit(beat:Float)
    {

    }

    function onPlayerNoteMiss(note:Note):Void
    {
        trace('Note Missed!');
    }

    function onPlayerGhostTap(direction:Int):Void
    {
        trace('Ghost Tap! Direction: ' + direction);
    }

    function onPlayerKeyRelease(direction:Int):Void
    {
        // Handle key release events if needed
        // trace('Key Released! Direction: ' + direction);
    }
}