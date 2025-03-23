// in PlayField.hx
package moon.game.obj;

import haxe.ui.styles.Style.StyleBorderType;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import moon.backend.gameplay.InputHandler;
import flixel.FlxG;
import flixel.group.FlxGroup;
import moon.game.obj.notes.*;
import moon.backend.gameplay.Timings;
import haxe.ds.StringMap; // Import the StringMap type

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
            var strumline = new Strumline(xVal + strumXs[i], 80, 'v-slice', isCPUPlayers[i], playerIDs[i], conductor);
            add(strumline);
            strumlines.push(strumline);

            var inputHandler = new InputHandler(null, playerIDs[i], strumline, conductor);
            inputHandlers.set(playerIDs[i], inputHandler);

            inputHandler.onNoteHit = (note, timing, isSustain) -> onNoteHit(playerIDs[i], note, timing, isSustain);
            inputHandler.onNoteMiss = (note) -> onNoteMiss(playerIDs[i], note);
        }

        // Little text for testing out the accuracy.
        tst = new FlxText(0, healthBar.y + 27);
        tst.text = 'Score: 0';
        tst.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT);
        tst.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        tst.x = FlxG.width / 2 + 120;
        add(tst);

        //< -- NOTES SETUP -- >//

        // Add the note spawner.
        noteSpawner = new NoteSpawner(chart.content.notes, strumlines, conductor);
        noteSpawner.scrollSpeed = chart.content.meta.scrollSpd;
        add(noteSpawner);

        // Set each input handler's notes.
        for (handler in inputHandlers.iterator())
            handler.thisNotes = noteSpawner.notes;
    }

    override public function update(dt:Float)
    {
        conductor.time += dt * 1000;

        var p1Handler:InputHandler = inputHandlers.get("p1");
        if (p1Handler != null)
        {
            p1Handler.justPressed = [
                MoonInput.justPressed(LEFT),
                MoonInput.justPressed(DOWN),
                MoonInput.justPressed(UP),
                MoonInput.justPressed(RIGHT)
            ];

            p1Handler.pressed = [
                MoonInput.pressed(LEFT),
                MoonInput.pressed(DOWN),
                MoonInput.pressed(UP),
                MoonInput.pressed(RIGHT)
            ];

            p1Handler.released = [
                MoonInput.released(LEFT),
                MoonInput.released(DOWN),
                MoonInput.released(UP),
                MoonInput.released(RIGHT)
            ];
        }

        super.update(dt);
        for (handler in inputHandlers.iterator())
            handler.update();

        healthBar.health = inputHandlers.get('p1').stats.health;
    }

    public function onNoteHit(playerID:String, note:Note, timing:String, isSustain:Bool)
    {
        if (playerID == 'p1')
            updateP1Stats();

        //final input = inputHandlers.get(playerID);
        //input.attachedChar
    }

    public function onNoteMiss(playerID:String, note:Note)
    {
        if (playerID == 'p1') updateP1Stats();
    }

    private function updateP1Stats():Void
    {
        final stat = inputHandlers.get('p1').stats;
        tst.text = 'Score: ${stat.score}';
        tst.x = FlxG.width / 2 + 120;
    }

    function beatHit(beat:Float):Void
    {
        healthBar.oppIcon.scale.set(1, 1);
        healthBar.playerIcon.scale.set(1, 1);
    }
}
