import moon.game.obj.Character;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

var tween:FlxTween; // making it a variable so I can stop it from overlapping.
function onExecute(values)
{
    if(tween != null && tween.active) tween.cancel();

    final charPos = getCharPositions(values[0]);
    tween = FlxTween.tween(game.camFollower, {x: charPos[0], y: charPos[1]}, 
    values[1], {ease: Reflect.field(FlxEase, values[2])});
}

function getCharPositions(charName:String):Array<Float>
{
    final chars = stage.chars;
    for (c in chars)
    {
        if (c.character + ('-' + c.ID) == charName)
            return [c.getMidpoint().x + c.data.camOffsets[0], c.getMidpoint().y + c.data.camOffsets[1]];
    }
    return [0, 0];
}