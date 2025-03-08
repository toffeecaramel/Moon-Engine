package moon.toolkit.chart_editor;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import moon.game.obj.notes.*;
import moon.dependency.MoonChart.NoteStruct;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.geom.ColorTransform;
import flixel.math.FlxMath;

class ChartGrid extends FlxSpriteGroup
{
    @:isVar public var time(default,set):Float = 0;
    public var conductor:Conductor;
    public var songLength:Float;
    public var lane:String;

    public var gridSize:Int = 54;
    public var lanes:Int = 4;
    public var noteData:Array<NoteStruct> = [];

    // -- Sprites -- //
    public var follower:MoonSprite = new MoonSprite();
    private var fullGrid:FlxTiledSprite;
    private var notes:FlxTypedSpriteGroup<Note> = new FlxTypedSpriteGroup<Note>();


    public function new(?x:Float = 0, ?y:Float = 0, lane:String = 'opponent')
    {
        super(x, y);
        this.lane = lane;
    }

    public function createGrid(notesData:Array<NoteStruct>, conductor:Conductor, songLength:Float = 0):ChartGrid
    {
        this.conductor = conductor;
        this.songLength = songLength;

        if (conductor == null)
        {
            trace("Conductor is null. Cannot create grid.", "ERROR");
            return null;
        }

        if (songLength <= 0)
        {
            trace("Song duration is invalid. Cannot create grid.", "ERROR");
            return null;
        }

        redrawGrid();

        follower.makeGraphic(gridSize, gridSize);
        follower.alpha = 0.8;
        add(follower);
        
        FlxTween.tween(follower, {alpha: 0.1}, 4, {ease: FlxEase.quadInOut});

        for(i in 0...notesData.length)
            if(notesData[i].lane == this.lane) addNote(notesData[i]);

        add(notes);
        return this;
    }

    public function addNote(data:NoteStruct)
    {
        notes.recycle(Note, function():Note
        {
            var note = new Note(data.data, data.time, data.type, 'v-slice', data.duration, conductor);
            note.state = CHART_EDITOR;
            note.setGraphicSize(gridSize, gridSize);
            note.updateHitbox();
            note.setPosition(data.data * gridSize, getTimePos(data.time));
            return note;
        });

        noteData.push(data);
    }

    public function redrawGrid():Void
    {
        if(fullGrid != null) remove(fullGrid);
        
        var base = FlxGridOverlay.create(gridSize, gridSize, gridSize * 2, gridSize * 2, true, 0xFF2a2a2c, 0xFF373639);
        fullGrid = new FlxTiledSprite(null, gridSize * lanes, gridSize);
        fullGrid.loadGraphic(base.graphic);
        fullGrid.alpha = 0.7;
        fullGrid.height = Math.ceil((songLength / conductor.stepCrochet) * gridSize);
        add(fullGrid);
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    @:noCompletion public function set_time(time:Float):Float
    {
        this.time = time;
        final scrollY = -getTimePos(time);
        fullGrid.y = notes.y = y + scrollY;
        return time;
    }

    public function getTimePos(time:Float)
        return FlxMath.remapToRange(time, 0, songLength, 0, (songLength / conductor.stepCrochet) * gridSize);
}