import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

final scale = 5;

function createReceptor(direction)
{
    final p = 'ingame/UI/notes/pixel/';

    strumNote.frames = Paths.getSparrowAtlas(p + 'strumline');

    strumNote.animation.addByPrefix(direction + '-static', direction + '-static', 24, true);
    strumNote.animation.addByPrefix(direction + '-press', direction + '-press', 24, false);
    strumNote.animation.addByPrefix(direction + '-confirm', direction + '-confirm', 24, false);

    strumNote.playAnim(direction + '-static', true);

    strumNote.animation.onFinish.add(function(animation:String)
    {
        if(animation == direction + '-confirm') strumNote.playAnim((!strumNote.isCPU) ? direction + '-press' : direction + '-static');
    });
    strumNote.scale.set(scale, scale);

    splash.frames = Paths.getSparrowAtlas(p + 'splash');

    splash.animation.addByPrefix('splash0', direction + '0', 40, false);
    splash.scale.set(scale + 0.2, scale + 0.2);
    //splash.blend = 0;

    sustainSplash.frames = Paths.getSparrowAtlas(p + 'pixelNoteHoldCover');

    sustainSplash.animation.addByPrefix('pre', 'loop0', 20, false);
    sustainSplash.animation.addByPrefix(direction + '-loop', 'loop0', 20, true);
    sustainSplash.animation.addByPrefix(direction + '-end', 'explode', 20, false);
    sustainSplash.playAnim(direction + '-end', true);
    sustainSplash.animation.onFinish.add(function(anim:String)
    {
        if(anim == direction + '-end') sustainSplash.visible = sustainSplash.active = false;
        else if (anim == 'pre') sustainSplash.playAnim(direction + '-loop', true);
    });

    sustainSplash.scale.set(scale, scale);
    sustainSplash.updateHitbox();

    splash.antialiasing = strumNote.antialiasing = sustainSplash.antialiasing = false;
}

function createStaticNote(skin, direction)
{
    staticNote.frames = Paths.getSparrowAtlas('ingame/UI/notes/pixel/staticNotes');

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
    if(judgement == 'sick' && !isSustain && note.lane != 'opponent')
    {
        splash.alpha = 0.8;
        splash.playAnim('splash0', true);
        splash.angle = FlxG.random.float(-360, 360);
    }

    final strumNote = note.receptor;

    final strumCenterX = strumNote.x + strumNote.width / 2;
    final strumCenterY = strumNote.y + strumNote.height / 2;

    if(arrTwn != null && arrTwn.active)
        arrTwn.cancel();
    
    strumNote.scale.set(scale + 1.2, scale + 1.2);
    arrTwn = FlxTween.tween(strumNote, {"scale.x": scale, "scale.y": scale}, 0.5, {ease: FlxEase.expoOut});

    if(isSustain)
        sustainSplash.setPosition(strumCenterX - sustainSplash.width / 2 + 135, strumCenterY - sustainSplash.height / 2 - 5);
}