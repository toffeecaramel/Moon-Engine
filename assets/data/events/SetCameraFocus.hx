import moon.game.obj.Character;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

var tween:FlxTween; // making it a variable so I can stop it from overlapping.
function onExecute(values)
{
    if(tween != null && tween.active) tween.cancel();

    final charPos = getCamPos(values.character);
    tween = FlxTween.tween(game.camFollower, {x: charPos[0], y: charPos[1]}, 
    values.duration, {ease: Reflect.field(FlxEase, values.ease)});
}

//for getting camera positions for the said character
var char:Character;
function getCamPos(charName:String):Array<Float>
{
    final chars = stage.chars;
    for (c in chars)
    {
        if (c.character + ('-' + c.ID) == charName)
            return [c.getMidpoint().x + c.data.camOffsets[0], c.getMidpoint().y + c.data.camOffsets[1]];
        else //these are for mainly converted charts, since its the possibly best way to get them working haha :'3
        {
            switch(charName)
            {
                case 'opponent': char = stage.opponents.members[0];
                case 'spectator': char = stage.spectators.members[0];
                case 'player': char = stage.players.members[0];
            }
            return [char.getMidpoint().x + char.data.camOffsets[0], char.getMidpoint().y + char.data.camOffsets[1]];
        }
    }
    return [0, 0];
}