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
    // Grid Stuff
    public var gridSize:Int = 54;
    public var laneCount:Int = 2;
    public var snapDiv:Int = 4;

    public var strumline:MoonSprite;
    public var strumArrows:FlxSpriteContainer;
    public var laneLines:FlxTypedSpriteGroup<MoonSprite>;
    public var gridContainer:FlxSpriteContainer;
    public var gridBG:FlxTiledSprite;
    var snapCursor:MoonSprite;

    public var notes:Array<Note> = [];
    public var noteData:Array<NoteStruct> = [];

    override public function create()
    {
        //TODO: get actual song selected by user.
        final song = 'darnell';
        final diff = 'hard';
        final mix = 'cow';

		camBACK.bgColor = 0x00000000;
        camMID.bgColor = 0x00000000;
        camFRONT.bgColor = 0x00000000;

        FlxG.mouse.visible = true;

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

        gridContainer = new FlxSpriteContainer();
        add(gridContainer);

        laneLines = new FlxTypedSpriteGroup<MoonSprite>();

        drawGrid(playback.fullLength);

        gridContainer.add(laneLines);

        for (n in chart.content.notes)
        {
            final laneIndex = chart.content.meta.lanes.indexOf(n.lane);
            if (laneIndex >= 0)
                addNote(n, laneIndex);
        }

        gridContainer.x = ((FlxG.width - gridContainer.width) / 2) + 216;
        gridContainer.y = 0;

        snapCursor = new MoonSprite().makeGraphic(gridSize, gridSize, FlxColor.WHITE);
        snapCursor.alpha = 0.4;
        snapCursor.camera = camMID;
        add(snapCursor);

        strumline = new MoonSprite().makeGraphic(Std.int(gridContainer.width), 5, FlxColor.WHITE);
        strumline.x = gridContainer.x;
        strumline.y = 120;
        strumline.alpha = 0.3;
        strumline.camera = camMID;
        add(strumline);

        strumArrows = new FlxSpriteContainer();
        for(a in 0...laneCount)
        {
            for(i in 0...4)
            {
                var ok = new MoonSprite().loadGraphic(Paths.image('toolbox/level-editor/strumline'), true, 32, 32);
                ok.animation.add('a', [i], 1, true);
                ok.animation.play('a');
                strumArrows.add(ok);

                ok.setGraphicSize(gridSize, gridSize);
                ok.antialiasing = false;
                ok.updateHitbox();

                ok.x = strumline.x + ((a * 4 + i) * gridSize);
                ok.y = strumline.y;

                ok.color = getColor(i);
                ok.alpha = 0.0001;
                ok.blend = ADD;

                ok.ID = i;
                ok.strID = chart.content.meta.lanes[a];
                //trace('${chart.content.meta.lanes[a]} & $i', "DEBUG");
            }
        }
        strumArrows.camera = camMID;
        add(strumArrows);

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
        strumline.alpha = FlxMath.lerp(strumline.alpha, 0.3, elapsed * 2);

        super.update(elapsed);

        if(FlxG.keys.justPressed.F)
            isFullscreen = !isFullscreen;

        if(!isFullscreen)
        {
            // ----- DATA ------ //
            final localX = FlxG.mouse.viewX - gridContainer.x;
            final localY = FlxG.mouse.viewY - gridContainer.y;

            final col = Math.floor(localX / gridSize);
            final laneIndex = Math.floor(col / 4);
            final data = col % 4;
            final snappedTime = getSnappedTime(localY);

            final addition = (FlxG.keys.pressed.SHIFT) ? 3 : 1;
            final advanceSecs = 500 * addition;

            // ----- Input Stuff ----- //
            if(FlxG.keys.justPressed.SPACE) playback.state = (playback.state != PLAY) ? PLAY : PAUSE;

            if(MoonInput.justPressed(UI_LEFT)) playback.time -= advanceSecs;
            else if (MoonInput.justPressed(UI_RIGHT)) playback.time += advanceSecs;

            if (FlxG.mouse.justPressed && FlxG.mouse.viewY > strumline.y)
                placeNote(col, localY);

            // ----- Upon note hit ----- //
            for (n in notes)
            {
                // If not hit yet, and time has passed, and the songi is playing
                if (n.strID != 'h' && conductor.time >= n.time && playback.state == PLAY)
                {
                    n.strID = 'h';
                    for(i in 0...strumArrows.members.length)
                    {
                        final s = cast(strumArrows.members[i], MoonSprite);
                        
                        if (s.strID.toLowerCase() == n.lane.toLowerCase() && s.ID == n.direction)
                        {
                            s.alpha = 1;
                            s.scale.set(1, 1);
                            //trace('${s.strID.toLowerCase()} to ${n.lane.toLowerCase()}', "DEBUG");
                        }
                    }
                }

                if (n.strID == 'h' && conductor.time < n.time)
                    n.strID = 'a';
            }

            // ----- Other ----- //
            for(s in strumArrows.members)
            {
                s.alpha = FlxMath.lerp(s.alpha, 0.0001, elapsed * 6);
                s.scale.x = s.scale.y = FlxMath.lerp(s.scale.x, 1.6, elapsed * 9);
            }

            FlxG.mouse.enabled = FlxG.mouse.visible = true;

            snapCursor.visible = (col >= 0 && col < chart.content.meta.lanes.length * 4);
            if (snapCursor.visible)
            {
                snapCursor.x = (laneIndex * 4 + data) * gridSize + gridContainer.x;
                snapCursor.y = getTimePos(snappedTime) + gridContainer.y;
            }

            gridContainer.y = strumline.y - getTimePos(playback.time);

            for (obj in notes)
                obj.active = obj.visible = obj.isOnScreen();
        }
        else
        {
            FlxG.mouse.enabled = FlxG.mouse.visible = false;
        }
    }

    function drawGrid(songLength:Float):Void
    {
        //---- grid ----//

        if (gridBG != null) gridContainer.remove(gridBG);

        final totalHeight = Math.ceil((songLength / conductor.stepCrochet) * gridSize);
        var base = FlxGridOverlay.create(gridSize, gridSize, gridSize * laneCount, gridSize * 2, true, 0xFF2a2a2c, 0xFF373639);

        final totalCols = chart.content.meta.lanes.length * 4;

        gridBG = new FlxTiledSprite(null, gridSize * totalCols, gridSize);
        gridBG.loadGraphic(base.graphic);
        gridBG.height = totalHeight;
        gridContainer.add(gridBG);

        //---- lines ----//

        if(laneLines.members.length > 0) laneLines.clear();

        final lineWidth = gridSize * totalCols;
        final beatCount = Math.ceil(songLength / conductor.crochet);

        for (i in 0...beatCount)
        {
            var line = new MoonSprite().makeGraphic(lineWidth, 2, (i % conductor.numerator == 0) ? 0xFF777777 : FlxColor.BLACK);
            line.x = 0;
            line.y = getTimePos(i * conductor.crochet);

            laneLines.add(line);
        }

        for (i in 0...chart.content.meta.lanes.length + 1)
        {
            var line = new MoonSprite().makeGraphic(2, Std.int(totalHeight), FlxColor.BLACK);
            line.x = i * 4 * gridSize;
            line.y = 0;
            laneLines.add(line);
        }
    }

    function placeNote(col, y):Void
    {
        if (col < 0 || col >= chart.content.meta.lanes.length * 4) return;

        final laneIndex = Math.floor(col / 4);
        final snappedTime = getSnappedTime(y);

        var ns:NoteStruct = {
            lane: chart.content.meta.lanes[laneIndex],
            data: col % 4,
            time: snappedTime,
            type: "normal",
            duration: 0
        };

        noteData.push(ns);
        addNote(ns, laneIndex);
        sfx('addNote-${FlxG.random.int(1, 6)}');
    }

    function addNote(data:NoteStruct, laneIndex:Int)
    {
        var note = new Note(data.data, data.time, data.type, 'mooncharter', data.duration, conductor);
        note.state = CHART_EDITOR;
        note.setGraphicSize(gridSize, gridSize);
        note.updateHitbox();
        note.lane = data.lane;

        note.x = (laneIndex * 4 + data.data) * gridSize;
        note.y = getTimePos(data.time);
        note.strID = 'a';

        gridContainer.add(note);

        if (note.duration > 0)
            drawSustain(note);

        noteData.push(data);
        notes.push(note);
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

    public function beatHit(curBeat:Float)
    {
        if(curBeat % conductor.numerator == 0)
        {
            strumline.alpha = 1;
        }
    }

    function getTimePos(time:Float):Float
        return FlxMath.remapToRange(time, 0, playback.fullLength, 0, (playback.fullLength / conductor.stepCrochet) * gridSize);

    function getSnappedTime(localY:Float):Float
    {
        final snapLen = conductor.crochet / snapDiv;
        final rawTime = localY / gridSize * conductor.stepCrochet;
        return Math.round(rawTime / snapLen) * snapLen;
    }

    function getColor(data:Int):FlxColor
    {
        final colors = [0xFF7f16ff, 0xFF37a5ff, 0xFF61d041, 0xFFff3f3f];
        return colors[data % colors.length];
    }

    private function sfx(p:String)
    {
        if(playback.state != PLAY)
            Paths.playSFX('toolkit/level-editor/$p');
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