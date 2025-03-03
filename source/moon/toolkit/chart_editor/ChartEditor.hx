package moon.toolkit.chart_editor;

import flixel.FlxG;
import moon.game.obj.Song;
import flixel.FlxState;

class ChartEditor extends FlxState
{
    var _chart:MoonChart;
    var _conductor:Conductor;
    var _playBack:Song;

    var grid:ChartGrid;

    override public function create()
    {
        //TODO: get actual song selected by user.
        final song = 'bittersweet sunset';
        final diff = 'hard';
        final mix = 'bf';

        _chart = new MoonChart(song, diff, mix);

        //TODO: get chart's time signature.
        _conductor = new Conductor(_chart.content.meta.bpm, 4, 4);
        _conductor.onBeat.add(beatHit);
        
        _playBack = new Song(
        [{name: song, mix: mix, type: Inst},
        {name: song, mix: mix, type: Voices_Opponent},
        {name: song, mix: mix, type: Voices_Player}],
        _conductor);

        grid = new ChartGrid(0, 0).createGrid(_chart.content.notes, _conductor, _playBack.fullLength);
        grid.screenCenter(X);
        add(grid);

        _playBack.state = PLAY;
    }

    override public function update(elapsed:Float)
    {
        _conductor.time = _playBack.time;
        super.update(elapsed);
        if(FlxG.keys.justPressed.R) grid.redrawGrid();
        if(FlxG.keys.justPressed.SPACE) _playBack.state = (_playBack.state != PLAY) ? PLAY : PAUSE;

        final addition = (FlxG.keys.pressed.SHIFT) ? 3 : 1;
        final advanceSecs = 500 * addition;
        if(MoonInput.justPressed(UI_LEFT)) _playBack.time -= advanceSecs;
        else if (MoonInput.justPressed(UI_RIGHT)) _playBack.time += advanceSecs;

        grid.time = _playBack.time;
    }

    public function beatHit(curBeat)
    {}
}