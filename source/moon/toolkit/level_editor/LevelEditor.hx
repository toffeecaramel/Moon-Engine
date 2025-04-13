package moon.toolkit.level_editor;

import haxe.ui.containers.VBox;
import haxe.ui.containers.TabView;
import haxe.ui.components.CheckBox;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.ComponentBuilder;
import flixel.FlxG;
import moon.game.obj.Song;
import flixel.FlxState;
import flixel.util.FlxColor;

class LevelEditor extends FlxState
{
    private var _chart:MoonChart;
    private var _conductor:Conductor;
    private var _playback:Song;

    public static var isMetronomeActive:Bool = false;

    var grid:ChartGrid;

    var taskbar:MenuBar;
    var tabs:VBox;

    override public function create()
    {
        //TODO: get actual song selected by user.
        final song = 'lit up';
        final diff = 'hard';
        final mix = 'bf';

        _chart = new MoonChart(song, diff, mix);

        //TODO: get chart's time signature.
        _conductor = new Conductor(_chart.content.meta.bpm, 4, 4);
        _conductor.onBeat.add(beatHit);
        
        _playback = new Song(
            song,
            mix,
            (diff == 'erect' || diff == 'nightmare'),
            _conductor
        );

        var bg = new MoonSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(30, 29, 31));
        add(bg);

        grid = new ChartGrid('opponent').createGrid(_chart.content.notes, _conductor, _playback.fullLength);
        grid.screenCenter(X);
        add(grid);

        _playback.state = PAUSE;

        taskbar = ComponentBuilder.fromFile('assets/data/ui/level-editor/taskbar.xml');
        final playback= taskbar.findComponent('playbackSpd');
        playback.onChange = (_) -> _playback.pitch = playback.value;
        add(taskbar);

        tabs = ComponentBuilder.fromFile('assets/data/ui/level-editor/tabs.xml');
        add(tabs);

        tabs.y = FlxG.height - tabs.height - 10;
    }

    override public function update(elapsed:Float)
    {
        _conductor.time = _playback.time;

        super.update(elapsed);

        //TODO: Remove this, it's debug only lol.
        if(FlxG.keys.justPressed.R) grid.redrawGrid();

        if(FlxG.keys.justPressed.SPACE) _playback.state = (_playback.state != PLAY) ? PLAY : PAUSE;

        final addition = (FlxG.keys.pressed.SHIFT) ? 3 : 1;
        final advanceSecs = 500 * addition;
        if(MoonInput.justPressed(UI_LEFT)) _playback.time -= advanceSecs;
        else if (MoonInput.justPressed(UI_RIGHT)) _playback.time += advanceSecs;

        grid.time = _playback.time;
    }

    public function beatHit(curBeat)
    {}
}