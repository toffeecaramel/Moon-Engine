package moon.toolkit.level_editor;

import flixel.tweens.FlxTween;
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
    public var chart:Chart;
    public var conductor:Conductor;
    public var playback:Song;

    public static var isMetronomeActive:Bool = false;

    public var miniPlayer:Miniplayer;
    public var grid:ChartGrid;
    public var taskbar:MenuBar;

    private var camMINIPLAYER:MoonCamera = new MoonCamera();
    private var camEDITOR:MoonCamera = new MoonCamera();

    override public function create()
    {
        //TODO: get actual song selected by user.
        final song = 'thorns';
        final diff = 'hard';
        final mix = 'noimix';

		camEDITOR.bgColor = 0x00000000;
        camMINIPLAYER.bgColor = 0x00000000;

		FlxG.cameras.add(camEDITOR, true);
		FlxG.cameras.add(camMINIPLAYER, false);

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

        miniPlayer = new Miniplayer(this);
        miniPlayer.camera = camMINIPLAYER;
        add(miniPlayer);

        grid = new ChartGrid('p1').createGrid(chart.content.notes, conductor, playback.fullLength);
        grid.screenCenter(X);
        add(grid);

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
            //TODO: Remove this, it's only for debug lol.
            if(FlxG.keys.justPressed.R) grid.redrawGrid();

            if(FlxG.keys.justPressed.SPACE) playback.state = (playback.state != PLAY) ? PLAY : PAUSE;

            final addition = (FlxG.keys.pressed.SHIFT) ? 3 : 1;
            final advanceSecs = 500 * addition;
            if(MoonInput.justPressed(UI_LEFT)) playback.time -= advanceSecs;
            else if (MoonInput.justPressed(UI_RIGHT)) playback.time += advanceSecs;

            grid.time = playback.time;
        }
        else
        {
            FlxG.mouse.enabled = FlxG.mouse.visible = false;
        }
    }

    public function beatHit(curBeat)
    {}

    var coolTwn:FlxTween;
    @:noCompletion function set_isFullscreen(isFS:Bool):Bool
    {
        this.isFullscreen = isFS;

        if(!isFullscreen)
        {
            camMINIPLAYER.zoom = 0.25;
            camMINIPLAYER.setPosition(-400, -170);
        }
        else
        {
            camMINIPLAYER.zoom = 1;
            camMINIPLAYER.setPosition();
        }

        return this.isFullscreen;
    }
}