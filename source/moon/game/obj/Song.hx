package moon.game.obj;

import sys.FileSystem;
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
	 * Sets the song's state, those being: `PLAY`, `PAUSE`, `STOP` & `KILL`.
	 */
	public var state(default, set):SongState = PLAY;

    public var onComplete:()->Void;
    private var conductor:Conductor;

    /**
     * Creates a song insance, useful for gameplay Inst & Voices.
     * @param audList 
     * @param conductor 
     */
    public function new(audList:Array<{name:String, mix:String, type:MusicType}>, conductor:Conductor)
    {
        super();
        this.conductor = conductor;

        for(i in 0...audList.length)
        {
            final item = audList[i];
            final audPath = Paths.audio('${item.name}/${item.mix}/${item.type}', 'songs');

            if(FileSystem.exists(audPath))
            {
                this.recycle(MoonSound, function():MoonSound
                {
                    var aud = cast new MoonSound().loadEmbedded(audPath, false, true, (onComplete != null) ? onComplete : null);
                    aud.type = item.type;
                    aud.strID = item.name;
                    FlxG.sound.list.add(cast aud);
                    return aud;
                });
            }
        }

        conductor.onStep.add(steps);
    }

    override public function update(dt:Float)
    {
        super.update(dt);
    }

    private function steps(step)
    {
        for (i in 0...this.members.length)
        if ((this.members[i].time >= conductor.time + 20 || this.members[i].time <= conductor.time - 20))
				resync();
    }

    /**
	 * Pauses all the songs playing and syncs their time.
	 */
	public function resync():Void
    {
        for(i in 0...this.members.length)
        {
            if(this.members[i] != null)
            {
                trace('Music is resyncing! from ${this.members[i].time} to ${conductor.time}', 'WARNING');

                state = PAUSE;
                (this.members[i].type == Inst) ? conductor.time = this.members[i].time : this.members[i].time = conductor.time;
                state = PLAY;
            }
        }
    }

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
}