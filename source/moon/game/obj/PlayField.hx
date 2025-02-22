package moon.game.obj;

import moon.game.obj.notes.NoteSpawner;
import flixel.FlxG;
import moon.game.obj.notes.Strumline;
import flixel.group.FlxGroup;

@:publicFields
class PlayField extends FlxGroup
{
    var conductor:Conductor;
    var playback:Song;

    var playerStrumline:Strumline;
    var opponentStrumline:Strumline;
    var noteSpawner:NoteSpawner;
    var chart:MoonChart;

    var song:String;
    var mix:String;
    var difficulty:String;

    public function new(song:String, difficulty:String, mix:String)
    {
        super();
        this.song = song;
        this.mix = mix;
        this.difficulty = difficulty;

        conductor = new Conductor(182, 4, 4);
		conductor.onBeat.add(beatHit);

        //TODO: Shorten this.
        playback = new Song(
			[{name: song, mix: mix, type: Inst}, 
			{name: song, mix: mix, type: Voices_Opponent}, 
			{name: song, mix: mix, type: Voices_Player}], 
        conductor);

        chart = new MoonChart(song, difficulty, mix);
            
        final xVal = (FlxG.width * 0.5);
        final xAddition = (FlxG.width * 0.25);

        //TODO: Actual skin support
        opponentStrumline = new Strumline(xVal - xAddition, 80, 'v-slice', true);
        opponentStrumline.strumID = 'opponent';
        add(opponentStrumline);

        playerStrumline = new Strumline(xVal + xAddition, 80, 'v-slice', false);
        playerStrumline.strumID = 'p1';
        add(playerStrumline);

        //TODO: make 2p support for note spawner
        noteSpawner = new NoteSpawner(chart.content.notes, [playerStrumline, opponentStrumline], conductor);
        add(noteSpawner);

		playback.state = PLAY;
    }

    override public function update(dt:Float)
    {
        conductor.time += dt * 1000;
        super.update(dt);
    }

    function beatHit(beat:Float)
    {

    }
}