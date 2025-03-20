import moon.game.obj.Character;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

var tween:FlxTween;
function onExecute(values)
{
    if(tween != null && tween.active) tween.cancel();
    tween = FlxTween.tween(game, {gameZoom: values[0]}, values[1], {ease: Reflect.field(FlxEase, values[2])});
}