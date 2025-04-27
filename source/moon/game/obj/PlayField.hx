package moon.game.obj;

import moon.game.obj.judgements.JudgementSprite;
import moon.game.obj.judgements.ComboNumbers;
import moon.backend.gameplay.PlayerStats;
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
    // -- VARIBALES

    public static var playfield:PlayField;

    var conductor:Conductor;
    var playback:Song;

    var noteSpawner:NoteSpawner;
    var chart:MoonChart;

    var inCutscene:Bool = true;
    var song:String;
    var mix:String;
    var difficulty:String;

    var inputHandlers:Map<String, InputHandler> = [];
    var strumlines:Array<Strumline> = [];

    var healthBar:HealthBar;
    
    var p1Judgements:JudgementSprite;
    var p1Combo:ComboNumbers;
    var stats:FlxText;

    var alpha(default, set):Float = 1;

    // -- CALLBACKS //

    /**
     * Called whenever a song is started.
     */
    var onSongStart:Void->Void;

    /**
     * Called whenever the song is restarted
     */
    var onSongRestart:Void->Void;

    /**
     * Called whenever a song is completed.
     */
    var onSongEnd:Void->Void; //TODO

    /**
     * Called when countdown is happening.
     */
    var onSongCountdown:Int->Void;

    /**
     * Called whenever a note gets hit (Good Hit.)
     */
    var onNoteHit:(String, Note, String, Bool)->Void;

    /**
     * Called whenever a note is missed (Bad Hit.)
     */
    var onNoteMiss:(String, Note)->Void;
    
    /**
     * Called whenever a key is pressed (if ghost tapping is off, it'll call onNoteMiss right after.)
     */
    var onGhostTap:Int->Void;

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

        //< -- COMBO SETUP -- >//
        //TODO: Skin for this one too :p
        p1Judgements = new JudgementSprite().init('moon-engine');
        p1Judgements.alpha = 0.0001;
        //just for preloading :p
        
        for(judgement => judgementVals in Timings.judgementsMap)
            p1Judgements.showJudgement(judgement, true, true);

        add(p1Judgements);

        p1Combo = new ComboNumbers().init('moon-engine');
        add(p1Combo);

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
            var strumline = new Strumline(xVal + strumXs[i], 68, 'v-slice', isCPUPlayers[i], playerIDs[i], conductor);
            add(strumline);
            strumlines.push(strumline);

            var inputHandler = new InputHandler(null, playerIDs[i], strumline, conductor);
			inputHandler.CPUMode = isCPUPlayers[i];
            inputHandlers.set(playerIDs[i], inputHandler);

            inputHandler.onNoteHit = (note, timing, isSustain) -> onHit(playerIDs[i], note, timing, isSustain);
            inputHandler.onNoteMiss = (note) -> onMiss(playerIDs[i], note);
            inputHandler.onGhostTap = (keyDir) -> if(onGhostTap != null) onGhostTap(keyDir);
        }

        // Little text for testing out the accuracy.
        // oh lol it doesn't even show accuracy anymore LMFAO
        stats = new FlxText(0, healthBar.y + 27);
        stats.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT);
        stats.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        add(stats);

        updateP1Stats(null);
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
        updateP1Stats(null);

        if(onSongRestart != null) onSongRestart();
        inCountdown = true;
    }

    var inCountdown:Bool = true;
    override public function update(dt:Float)
    {
        if(!inCutscene) conductor.time += (dt * 1000) * playback.pitch;
        Global.allowInputs = !inCutscene;

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

    function onHit(playerID:String, note:Note, timing:String, isSustain:Bool)
    {
        if (playerID == 'p1')
            updateP1Stats(timing);

        if(onNoteHit != null) onNoteHit(playerID, note, timing, isSustain);

        //final input = inputHandlers.get(playerID);
        //input.attachedChar
    }

    function onMiss(playerID:String, note:Note)
    {
        if (playerID == 'p1')
        {
            updateP1Stats('miss');
            p1Combo.comboRoll(0, 2, true);
            inputHandlers.get('p1').stats.combo = 0;
        }
        if(onNoteMiss != null) onNoteMiss(playerID, note);
    }

    private function updateP1Stats(judgement):Void
    {
        final stat = inputHandlers.get('p1').stats;
        stats.text = 'Score: ${stat.score} // Misses: ${stat.misses} // Accuracy: ${stat.accuracy}%';
        stats.screenCenter(X);
        stat.combo++;

        if(judgement != null)
        {
            p1Judgements.color = Timings.getParameters(judgement)[4];
            
            p1Judgements.screenCenter();
            p1Judgements.y -= 60;
            p1Judgements.showJudgement(judgement, true, true);
        }
        
        //TODO: custom positioning
        p1Combo.combo = stat.combo;
        p1Combo.displayCombo(true, true);
        p1Combo.numsColor = p1Judgements.color;
        p1Combo.screenCenter();
    }

    function beatHit(beat:Float):Void
    {
        healthBar.oppIcon.scale.set(1, 1);
        healthBar.playerIcon.scale.set(1, 1);

       // <- COUNTDOWN STUFF -> //
       if(inCountdown && !inCutscene)
       {
            switch(beat)
            {
                case 0: 
                    playback.state = PLAY;
                    inCountdown = false;
                    if(onSongStart != null) onSongStart();
                case -1: FlxG.sound.play(Paths.sound('game/countdown/intro-0', 'sounds'));

                default: if(beat >= -4)FlxG.sound.play(Paths.sound('game/countdown/intro${beat+1}', 'sounds'));
            }

            if(onSongCountdown != null) onSongCountdown(Std.int(beat));
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