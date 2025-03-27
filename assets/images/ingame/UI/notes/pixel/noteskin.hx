import flixel.FlxG;

final scale = 0.2;

function createReceptor(direction)
{
    final p = 'ingame/UI/notes/pixel/';
    final pa = 'ingame/UI/notes/v-slice/'; // just the path so I dont need to do crazy copy pasting

    strumNote.frames = Paths.getSparrowAtlas(pa + 'strumline');

    strumNote.animation.addByPrefix(direction + '-static', direction + '-static', 24, true);
    strumNote.animation.addByPrefix(direction + '-press', direction + '-press', 24, false);
    strumNote.animation.addByPrefix(direction + '-confirm', direction + '-confirm', 24, false);

    strumNote.playAnim(direction + '-static', true);

    strumNote.animation.onFinish.add(function(animation:String)
    {
        if(animation == direction + '-confirm') strumNote.playAnim((!strumNote.isCPU) ? direction + '-press' : direction + '-static');
    });
    strumNote.scale.set(scale, scale);

    splash.frames = Paths.getSparrowAtlas(pa + 'splash');

    splash.animation.addByPrefix('splash0', direction + '0', 32, false);
    splash.scale.set(scale + 0.2, scale + 0.2);
    
    splash.blend = 0;

    splash.antialiasing = strumNote.antialiasing = false;
}

function createStaticNote(skin, direction)
{
    staticNote.frames = Paths.getSparrowAtlas('ingame/UI/notes/' + skin + '/staticArrows');

    staticNote.animation.addByPrefix(direction, direction + '0', 24, true);
    staticNote.animation.addByPrefix(direction + '-hold', direction + '-hold0', 24, true);
    staticNote.animation.addByPrefix(direction + '-holdEnd', direction +'-holdend0', 24, true);
    staticNote.antialiasing = true;
    staticNote.scale.set(scale, scale);
}

function onNoteHit(note, judgement, isSustain)
{
    if(judgement == 'sick' && !isSustain)
    {
        splash.angle = FlxG.random.float(-360, 360);
    }
}