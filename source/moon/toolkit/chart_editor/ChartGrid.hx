package moon.toolkit.chart_editor;

import moon.dependency.MoonChart.NoteStruct;
import flixel.FlxSprite;
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

    public var gridSize:Int = 50;
    public var lanes:Int = 4;

    public var gridLineColor:FlxColor = FlxColor.WHITE;
    public var gridBackgroundColor:FlxColor = FlxColor.BLACK;

    private var fullGrid:FlxTiledSprite;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);
    }

    public function createGrid(notes:Array<NoteStruct>, conductor:Conductor, songLength:Float = 0):ChartGrid
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

        return this;
    }

    public function redrawGrid():Void
    {
        clear();
        
        var base = FlxGridOverlay.create(gridSize, gridSize, gridSize * 2, gridSize * 2, true, gridLineColor, gridBackgroundColor);
        fullGrid = new FlxTiledSprite(null, gridSize * lanes, gridSize);
        fullGrid.loadGraphic(base.graphic);
        fullGrid.setPosition(x, y);

        fullGrid.height = Math.ceil((songLength / conductor.stepCrochet) * gridSize);
        add(fullGrid);
    }

    @:noCompletion public function set_time(time:Float):Float
    {
        this.time = time;
        final scrollY = -getTimePos(time);
        fullGrid.y = y + scrollY;
        return time;
    }

    public function getTimePos(time:Float)
        return FlxMath.remapToRange(time, 0, songLength, 0, (songLength / conductor.stepCrochet) * gridSize);
}