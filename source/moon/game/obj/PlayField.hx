package moon.game.obj;

import flixel.FlxG;
import moon.game.obj.notes.Strumline;
import flixel.group.FlxGroup;

@:publicFields
class PlayField extends FlxGroup
{
    var conductor:Conductor;
    var playback:Song;

    var song:String;
    var mix:String;
    var difficulty:String;

    var playerStrumline:Strumline;
    var opponentStrumline:Strumline;

    public function new(song:String, mix:String, difficulty:String)
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
            
        final xVal = (FlxG.width * 0.5);
        final xAddition = (FlxG.width * 0.25);

        //TODO: Actual skin support
        opponentStrumline = new Strumline(xVal - xAddition, 80, 'v-slice', true);
        add(opponentStrumline);

        playerStrumline = new Strumline(xVal + xAddition, 80, 'v-slice', false);
        add(playerStrumline);

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