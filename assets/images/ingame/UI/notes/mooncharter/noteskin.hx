import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

final scale = 3;

function createReceptor(direction)
{
    final p = 'ingame/UI/notes/mooncharter/';
	spacing = 7;
    judgementsSkin = 'moon-pixel';

    // strum notes
    strumNote.frames = Paths.getSparrowAtlas(p + 'strumline');
    strumNote.animation.addByPrefix(direction + '-static', direction + '-static', 24, true);
    strumNote.animation.addByPrefix(direction + '-press', direction + '-press', 24, false);
    strumNote.animation.addByPrefix(direction + '-confirm', direction + '-confirm', 24, false);
    strumNote.playAnim(direction + '-static', true);

    strumNote.animation.onFinish.add((animation) ->
    {
        if(animation == direction + '-confirm') strumNote.playAnim((!strumNote.isCPU) ? direction + '-press' : direction + '-static');
    });
    strumNote.scale.set(scale, scale);

    strumNote.antialiasing = false;
}

function createStaticNote(skin, direction)
{
    staticNote.frames = Paths.getSparrowAtlas('ingame/UI/notes/mooncharter/staticNotes');

    staticNote.animation.addByPrefix(direction, direction + '0', 24, true);
    staticNote.animation.addByPrefix(direction + '-hold', direction + '-hold0', 24, true);
    staticNote.animation.addByPrefix(direction + '-holdEnd', direction +'-holdend0', 24, true);
    staticNote.antialiasing = false;
    staticNote.scale.set(scale, scale);
    staticNote.updateHitbox();
}

var arrTwn:FlxTween;
function onNoteHit(note, judgement, isSustain)
{
    final strumNote = note.receptor;
    
    if(arrTwn != null && arrTwn.active)
        arrTwn.cancel();
    
    strumNote.scale.set(scale + 1.2, scale + 1.2);
    arrTwn = FlxTween.tween(strumNote, {"scale.x": scale, "scale.y": scale}, 0.5, {ease: FlxEase.expoOut});
}