import moon.global_obj.TextScroll;
import moon.dependency.MoonSprite;
import flixel.text.FlxText;

function onCreate()
{
    // This right here!!
    var test = new MoonSprite();
    test.loadGraphic(Paths.image('menus/freeplay/pinkBack'));
    test.color = 0xFFffd863;
    //test.color = FlxColor.TRANSPARENT;
    frontBG.add(test);

    var test = new TextScroll(0, 20, 'BLUEBALLS BOY >:3', 130, 32, false);
    test.blend = 12; 
    frontBG.add(test);
}