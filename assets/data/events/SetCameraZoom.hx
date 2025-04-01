import moon.game.obj.Character;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

var tween:FlxTween;
function onExecute(values)
{
    if(tween != null && tween.active) tween.cancel();
    tween = FlxTween.tween(game, {gameZoom: values.zoom}, values.duration, {ease: Reflect.field(FlxEase, values.ease)});
}