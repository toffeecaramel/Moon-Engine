package;

import flixel.math.FlxMath;
import moon.game.obj.PlayField;
import flixel.addons.display.waveform.FlxWaveform;
import moon.game.obj.judgements.ComboNumbers;
import haxe.ui.ComponentBuilder;
import flixel.FlxG;
import flixel.FlxState;
import haxe.ui.components.Button;
import sys.io.File;
import haxe.io.Path;
import haxe.zip.Writer;
import haxe.zip.Entry;
import haxe.io.Bytes;
import haxe.ds.List;

class TestState extends FlxState
{
    var waveform:FlxWaveform;
    var playfield:PlayField;
    override public function create():Void
    {
        super.create();
        FlxG.mouse.useSystemCursor = true;

        // addons file test
        /*var files = new Map<String, Bytes>();
        files.set("nya/text.txt", Bytes.ofString("Hello world! I am here to spread an important message.\nI got created by code.\nYes.\nThat's right.\n\n\nIsn't that cool?"));
        files.set("data.json", Bytes.ofString('{"hi": true}'));
        Mchr.create(files, "test.mchr");*/

        //var fileList = Mchr.listFiles("test.mchr");
        //trace('Files: $fileList', "DEBUG");

        //var fileContent = Mchr.extract(Paths.getPath("test.mchr", null), "nya/text.txt");
        //trace('Content of text: ${fileContent.toString()}', "DEBUG");

        waveform = new FlxWaveform(0, 0, FlxG.width, Std.int(FlxG.height / 2 - 50));
        add(waveform);
        
        playfield = new PlayField('roses', 'hard', 'noimix');
        add(playfield);
        
        waveform.loadDataFromFlxSound(playfield.playback.inst[0]);
        waveform.waveformTime = 0;
        waveform.waveformDuration = 600;
        waveform.waveformColor = 0xFFFFFFFF;
        waveform.waveformRMSColor = 0xFF94ABFF;
        waveform.waveformBarSize = 4;
        waveform.waveformBarPadding = 0;
        waveform.waveformDrawMode = COMBINED;
        waveform.screenCenter();
        waveform.alpha = 0.5;

        playfield.conductor.onBeat.add((beat)->
        {
            waveform.alpha = 1;
            waveform.scale.set(1.2, 1.2);

            if ((beat % playfield.conductor.numerator) == 0)
            {
                FlxG.sound.play(Paths.sound('debug/metronome', 'sounds'));
            }
            else FlxG.sound.play(Paths.sound('debug/metronomePeak', 'sounds'));

        });
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        waveform.alpha = FlxMath.lerp(waveform.alpha, 0.1, elapsed * 6);
        waveform.scale.x = waveform.scale.y = FlxMath.lerp(waveform.scale.x, 1, elapsed * 6);
        if (playfield.playback.inst[0].playing)
        {
            // Set our waveform's time to the music's time, keeping them in sync.
            waveform.waveformTime = playfield.playback.inst[0].time;
        }
    }
}