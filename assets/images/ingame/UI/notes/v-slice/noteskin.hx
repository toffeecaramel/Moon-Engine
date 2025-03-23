import flixel.FlxG;

final scale = 0.6;

function createReceptor()
{
    //trace("Hello there! From noteskin~", "DEBUG");

    // Rescale the note cause its big af
    strumNote.scale.set(scale, scale);

    // Set the antialiasing to true otherwise it looks weird
    strumNote.antialiasing = true;

    // Reminder for you if you're modding a noteskin:
    // WHENEVER you change scale, or anything related to size,
    // Don't forget to update hitbox or else the sprites positions will look off! ^^
    strumNote.updateHitbox();

    splash.scale.set(scale + 0.2, scale + 0.2);

    // Blend Mode. 0 is ADD! you can reference all the blend modes from here: https://api.openfl.org/openfl/display/BlendMode.html
    splash.blend = 0;

    // Splash's total animations(variations).
    splash.totalAnims = 2;
    splash.antialiasing = true;
}

function createStaticNote()
{
    staticNote.scale.set(scale, scale);
    staticNote.antialiasing = true;
}

/**
 * This function is called whenever a note is hit.
 * @param note      The note that is being hit.
 * @param judgement The judgement got from hitting said note.
 * @param isSustain Whether or not its a sustain note.
 */
function onNoteHit(note, judgement, isSustain)
{
    splash.angle = FlxG.random.float(-360, 360);
}