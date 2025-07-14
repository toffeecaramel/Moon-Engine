package moon.toolkit.level_editor;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteContainer;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import openfl.geom.ColorTransform;

import haxe.ui.containers.VBox;
import haxe.ui.containers.TabView;
import haxe.ui.components.CheckBox;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.ComponentBuilder;

import moon.game.obj.Song;
import moon.game.obj.notes.*;
import moon.backend.data.Chart.NoteStruct;

class LevelEditor extends FlxState
{
    // ----------------------- //
    // Setup
    public var chart:Chart;
    public var conductor:Conductor;
    public var playback:Song;

    //public var miniPlayer:Miniplayer;
    public var taskbar:MenuBar;

    private var camBACK:MoonCamera = new MoonCamera();
    private var camMID:MoonCamera = new MoonCamera();
    private var camFRONT:MoonCamera = new MoonCamera();

    public static var isMetronomeActive:Bool = false;

    // ----------------------- //
    // Grid config
    public var gridSize:Int = 54;
    public var laneCount:Int = 4;

    // Data
    public var gridContainer:FlxSpriteContainer;
    public var noteData:Array<NoteStruct> = [];
    public var gridBG:FlxTiledSprite;

    override public function create()
    {
        //TODO: get actual song selected by user.
        final song = 'darnell';
        final diff = 'hard';
        final mix = 'bf';

		camBACK.bgColor = 0x00000000;
        camMID.bgColor = 0x00000000;
        camFRONT.bgColor = 0x00000000;

        FlxG.mouse.useSystemCursor = FlxG.mouse.visible = true;

		FlxG.cameras.add(camBACK, true);
		FlxG.cameras.add(camMID, false);
        FlxG.cameras.add(camFRONT, false);

        chart = new Chart(song, diff, mix);

        //TODO: get chart's time signature.
        conductor = new Conductor(chart.content.meta.bpm, chart.content.meta.timeSignature[0], chart.content.meta.timeSignature[0]);
        conductor.onBeat.add(beatHit);
        
        playback = new Song(
            song,
            mix,
            (diff == 'erect' || diff == 'nightmare'),
            conductor
        );

        var bg = new MoonSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(30, 29, 31));
        add(bg);

        //miniPlayer = new Miniplayer(this);
        //miniPlayer.camera = camMID;
        //add(miniPlayer);

        laneCount = 4;

        gridContainer = new FlxSpriteContainer();
        add(gridContainer);

        drawGrid(playback.fullLength);

        for (n in chart.content.notes)
            if (n.lane == "opponent")
                addNote(n);

        gridContainer.x = (FlxG.width - gridContainer.width) / 2;
        gridContainer.y = 0;

        playback.state = PAUSE;

        taskbar = ComponentBuilder.fromFile('assets/data/ui/level-editor/taskbar.xml');
        final playbackSldr = taskbar.findComponent('playbackSpd');
        playbackSldr.onChange = (_) -> playback.pitch = playbackSldr.value;
        add(taskbar);

        isFullscreen = false;
    }

    var isFullscreen(default, set):Bool = false;
    override public function update(elapsed:Float)
    {
        conductor.time = playback.time;

        super.update(elapsed);

        if(FlxG.keys.justPressed.F)
            isFullscreen = !isFullscreen;

        if(!isFullscreen)
        {
            FlxG.mouse.enabled = FlxG.mouse.visible = true;

            if(FlxG.keys.justPressed.SPACE) playback.state = (playback.state != PLAY) ? PLAY : PAUSE;

            final addition = (FlxG.keys.pressed.SHIFT) ? 3 : 1;
            final advanceSecs = 500 * addition;
            if(MoonInput.justPressed(UI_LEFT)) playback.time -= advanceSecs;
            else if (MoonInput.justPressed(UI_RIGHT)) playback.time += advanceSecs;

            gridContainer.y = -getTimePos(playback.time);
        }
        else
        {
            FlxG.mouse.enabled = FlxG.mouse.visible = false;
        }
    }

    function drawGrid(songLength:Float):Void
    {
        if (gridBG != null) gridContainer.remove(gridBG);

        final totalHeight = Math.ceil((songLength / conductor.stepCrochet) * gridSize);
        var base = FlxGridOverlay.create(gridSize, gridSize, gridSize * laneCount, gridSize * 2, true, 0xFF2a2a2c, 0xFF373639);

        gridBG = new FlxTiledSprite(null, gridSize * laneCount, gridSize);
        gridBG.loadGraphic(base.graphic);
        gridBG.height = totalHeight;
        gridContainer.add(gridBG);
    }

    function addNote(data:NoteStruct)
    {
        var note = new Note(data.data, data.time, data.type, 'mooncharter', data.duration, conductor);
        note.state = CHART_EDITOR;
        note.setGraphicSize(gridSize, gridSize);
        note.updateHitbox();

        note.x = data.data * gridSize;
        note.y = getTimePos(data.time);

        gridContainer.add(note);

        if (note.duration > 0)
            drawSustain(note);

        noteData.push(data);
    }

    function drawSustain(note:Note)
    {
        final susHeight = getTimePos(note.time + note.duration) - getTimePos(note.time);
        var sus = new MoonSprite().makeGraphic(10, Std.int(susHeight), getColor(note.direction));
        sus.x = note.x + (gridSize - sus.width) / 2;
        sus.y =  note.y + gridSize;
        sus.pixels.fillRect(new openfl.geom.Rectangle(0, sus.height - 8, sus.width, 8), FlxColor.WHITE);
        gridContainer.add(sus);
    }

    public function beatHit(curBeat)
    {}

    function getTimePos(time:Float):Float
        return FlxMath.remapToRange(time, 0, playback.fullLength, 0, (playback.fullLength / conductor.stepCrochet) * gridSize);

    function getColor(data:Int):FlxColor
    {
        final colors = [0xFF7f16ff, 0xFF37a5ff, 0xFF61d041, 0xFFff3f3f];
        return colors[data % colors.length];
    }

    @:noCompletion function set_isFullscreen(isFS:Bool):Bool
    {
        this.isFullscreen = isFS;

        if(!isFullscreen)
        {
            camFRONT.zoom = 0.25;
            camFRONT.setPosition(-400, -170);
        }
        else
        {
            camFRONT.zoom = 1;
            camFRONT.setPosition();
        }

        return this.isFullscreen;
    }
}