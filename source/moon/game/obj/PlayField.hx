package moon.game.obj;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import haxe.ui.styles.Style.StyleBorderType;
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

    var noteSpawner:NoteSpawner;
    var chart:MoonChart;

    var song:String;
    var mix:String;
    var difficulty:String;

    var inputHandlers:Map<String, InputHandler> = [];
    var strumlines:Array<Strumline> = [];

    var healthBar:HealthBar;
    
    var tst:FlxText;

    var alpha(default, set):Float = 1;

    // -- CALLBACKS
    var onSongRestart:Void->Void;

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
            song,
            mix,
            (difficulty == 'erect' || difficulty == 'nightmare'),
            conductor
        );
        playback.state = PAUSE;

        //< -- HEALTHBAR SETUP -- >//
        healthBar = new HealthBar(chart.content.meta.opponents[0], chart.content.meta.players[0]);
        add(healthBar);
        healthBar.setPosition(0, FlxG.height - healthBar.height + 32);
        healthBar.screenCenter(X);
    
        //< -- STRUMLINES & INPUTS SETUP -- >//
        strumlines = [];

        final xVal = (FlxG.width * 0.5);
        final xAddition = (FlxG.width * 0.25);
        final strumXs = [-xAddition, xAddition];
		
        final playerIDs = ["opponent", "p1"];
        final isCPUPlayers = [true, false];

        for (i in 0...playerIDs.length)
        {
            //TODO: Skins lol
            var strumline = new Strumline(xVal + strumXs[i], 80, 'pixel', isCPUPlayers[i], playerIDs[i], conductor);
            add(strumline);
            strumlines.push(strumline);

            var inputHandler = new InputHandler(null, playerIDs[i], strumline, conductor);
			inputHandler.CPUMode = isCPUPlayers[i];
            inputHandlers.set(playerIDs[i], inputHandler);

            inputHandler.onNoteHit = (note, timing, isSustain) -> onNoteHit(playerIDs[i], note, timing, isSustain);
            inputHandler.onNoteMiss = (note) -> onNoteMiss(playerIDs[i], note);
        }

        // Little text for testing out the accuracy.
        // oh lol it doesn't even show accuracy anymore LMFAO
        tst = new FlxText(0, healthBar.y + 27);
        tst.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT);
        tst.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        add(tst);

        updateP1Stats();
        setupNotes();

        conductor.time = -(conductor.crochet * 6);
    }

    function setupNotes()
    {
        //< -- NOTES SETUP -- >//
        // Add the note spawner.
        noteSpawner = new NoteSpawner(chart.content.notes, strumlines, conductor);
        noteSpawner.scrollSpeed = chart.content.meta.scrollSpd;
        add(noteSpawner);

        // Set each input handler's notes.
        for (handler in inputHandlers.iterator())
            handler.thisNotes = noteSpawner.notes;
    }

    function restartSong()
    {
        playback.time = 0;
        playback.state = PAUSE;
        conductor.time = -(conductor.crochet * 6);
        
        for (handler in inputHandlers.iterator())
            handler.stats.reset();

        for(strum in strumlines)
            for(receptor in strum.receptors)
            {
                receptor.notesGroup.clear();
                receptor.sustainsGroup.clear();
                receptor.sustainSplash.despawn(true);
            }
        
        for (handler in inputHandlers.iterator())
        {
            handler.thisNotes = [];
            handler.heldSustains.clear();
        }

        noteSpawner.clear();
        noteSpawner.killMembers();
        remove(noteSpawner, true);

        setupNotes();
        updateP1Stats();

        if(onSongRestart != null) onSongRestart();
        inCountdown = true;
    }

    var inCountdown:Bool = true;
    override public function update(dt:Float)
    {
        conductor.time += (dt * 1000) * playback.pitch;

        super.update(dt);
        for (handler in inputHandlers.iterator())
		{
			handler.justPressed = [
                MoonInput.justPressed(LEFT),
                MoonInput.justPressed(DOWN),
                MoonInput.justPressed(UP),
                MoonInput.justPressed(RIGHT)
            ];

            handler.pressed = [
                MoonInput.pressed(LEFT),
                MoonInput.pressed(DOWN),
                MoonInput.pressed(UP),
                MoonInput.pressed(RIGHT)
            ];

            handler.released = [
                MoonInput.released(LEFT),
                MoonInput.released(DOWN),
                MoonInput.released(UP),
                MoonInput.released(RIGHT)
            ];
            handler.update();
		}

        //TODO: REMOVE, PLACEHOLDER.
        if(FlxG.keys.justPressed.I) playback.pitch -= 0.05;
        else if (FlxG.keys.justPressed.O) playback.pitch += 0.05;

        healthBar.health = inputHandlers.get('p1').stats.health;
    }

    function onNoteHit(playerID:String, note:Note, timing:String, isSustain:Bool)
    {
        if (playerID == 'p1')
            updateP1Stats();

        //final input = inputHandlers.get(playerID);
        //input.attachedChar
    }

    function onNoteMiss(playerID:String, note:Note)
    {
        if (playerID == 'p1') updateP1Stats();
    }

    private function updateP1Stats():Void
    {
        final stat = inputHandlers.get('p1').stats;
        tst.text = 'Score: ${stat.score} // Misses: ${stat.misses} // Accuracy: ${stat.accuracy}%';
        tst.screenCenter(X);
    }

    function beatHit(beat:Float):Void
    {
        healthBar.oppIcon.scale.set(1, 1);
        healthBar.playerIcon.scale.set(1, 1);

       // <- COUNTDOWN STUFF -> //
       if(inCountdown)
       {
            switch(beat)
            {
                case 0: playback.state = PLAY;
                inCountdown = false;
                case -1: FlxG.sound.play(Paths.sound('game/countdown/intro-0', 'sounds'));

                default: if(beat >= -4)FlxG.sound.play(Paths.sound('game/countdown/intro${beat+1}', 'sounds'));
            }
       }
    }

    @:noCompletion public function set_alpha(val:Float):Float
    {
        this.alpha = val;
        for (obj in this.members)
        {
            if(Std.isOfType(obj, FlxSprite))
                cast(obj, FlxSprite).alpha = this.alpha;
        }

        //gotta apply separately :T
        // eh.
        for(strum in strumlines)
            for(receptor in strum.receptors)
                receptor.alpha = this.alpha;

        return this.alpha;
    }
}