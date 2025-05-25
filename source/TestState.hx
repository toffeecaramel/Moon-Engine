package;

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
    var testCombo:ComboNumbers;
    override public function create():Void
    {
        super.create();
        FlxG.mouse.useSystemCursor = true;

        /*var files = new Map<String, Bytes>();
        files.set("nya/text.txt", Bytes.ofString("Hello world! I am here to spread an important message.\nI got created by code.\nYes.\nThat's right.\n\n\nIsn't that cool?"));
        files.set("data.json", Bytes.ofString('{"hi": true}'));
        Mchr.create(files, "test.mchr");*/

        //var fileList = Mchr.listFiles("test.mchr");
        //trace('Files: $fileList', "DEBUG");

        var fileContent = Mchr.extract(Paths.getPath("test.mchr", null), "nya/text.txt");
        trace('Content of text: ${fileContent.toString()}', "DEBUG");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}