import flixel.FlxG;
import moon.global_obj.TextScroll;
import moon.dependency.MoonSprite;
import flixel.text.FlxText;

function onCreate()
{
    var test = new MoonSprite();
    test.makeGraphic(600, FlxG.height, 0xFFffd863);
    behindBG.add(test);

    var test = new TextScroll(0, 20, 'BLUEBALLS BOY >:3', 130, 32, false);
    test.blend = 12; 
    behindBG.add(test);
}