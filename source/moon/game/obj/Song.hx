package moon.game.obj;

import flixel.FlxG;
import moon.dependency.MoonSound.MusicType;
import flixel.group.FlxGroup.FlxTypedGroup;

enum SongState {
	PLAY;
	PAUSE;
	STOP;
	KILL;
}

class Song extends FlxTypedGroup<MoonSound>
{
    /**
	 * The song's state, those being: `PLAY`, `PAUSE`, `STOP` & `KILL`.
	 */
	public var state(default, set):SongState = PLAY;

    /**
	 * The song's pitch.
	 */
	public var pitch(default, set):Float = 1;

	/**
	 * The song's current time.
	 */
	@:isVar public var time(get, set):Float = 0;

    /**
	 * Get the song's full time.
	 */
	@:isVar public var fullLength(get, never):Float = 0;

    public var onComplete:()->Void;

    /**
     * Creates a song insance, useful for gameplay Inst & Voices.
     * @param song The name of the song
     * @param char The character mix
     * @param useErect Whether or not to use the erect version of the song 
     */
    public function new(song:String, char:String, ?useErect:Bool)
    {
        super();

        var audList =[Voices_Opponent, Voices_Player, Inst];

        for(i in 0...audList.length)
        {
            final item = audList[i];

            final erectOrNot = (useErect) ? "-erect" : "";
            final items = '$song/$char/${audList[i]}$erectOrNot';
            final audPath = Paths.sound('$items', 'songs');

            if(Paths.fileExists('assets/songs/$items.ogg'))
            {
                this.recycle(MoonSound, function():MoonSound
                {
                    var aud = cast new MoonSound().loadEmbedded(audPath, false, true);
                    aud.type = audList[i];
                    aud.strID = song;
                    FlxG.sound.list.add(cast aud);
                    return aud;
                });
            }
        }

        Conductor.onStep.add(steps);
    }

    override public function update(dt:Float)
    {
        super.update(dt);
    }

    private function steps()
    {
        for (i in 0...this.members.length)
        if ((this.state == PLAY) && (this.members[i].time >= Conductor.time + 20 || this.members[i].time <= Conductor.time - 20))
				resync(this.members[i]);
    }

    /**
	 * Sets said member to it's supposed song position.
	 */
	public function resync(member:MoonSound):Void
        (member.type == Inst) ? Conductor.time = member.time : member.time = Conductor.time;

    ////////////////////////////////////////////////////////////////////////////////////

	@:noCompletion public function set_state(state:SongState = PLAY):SongState
    {
        this.state = state;
        for (i in 0...members.length)
        {
            switch(state)
            {
                case PLAY: members[i].play();
                case PAUSE: members[i].pause();
                case STOP: members[i].stop();
                case KILL: 
                    FlxG.sound.list.remove(this.members[i]);
                    members[i].kill();
            }
        }
        return state;
    }

    @:noCompletion public function set_pitch(value:Float):Float
    {
        pitch = value;

        for (i in 0...members.length)
            members[i].pitch = pitch;

        return value;
    }

    @:noCompletion public function get_time():Float
    {
        var lastTime:Float = 0;
        for (i in 0...members.length)
            lastTime = members[i].time;

        return lastTime;
    }		

    @:noCompletion public function set_time(value:Float):Float
    {
        time = value;
        for(i in 0...members.length)
            members[i].time = value;

        return value;
    }
    
    @:noCompletion public function get_fullLength():Float
    {
        var lastLength:Float = 0;
        for (i in 0...members.length)
            lastLength = members[i].length;

        return lastLength;
    }
}