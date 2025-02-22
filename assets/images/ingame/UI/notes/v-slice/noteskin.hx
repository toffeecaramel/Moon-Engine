final scale = 0.6;

function createStrumNote()
{
    //trace("Hello there! From noteskin~", "DEBUG");
    receptor.scale.set(scale, scale);
    receptor.antialiasing = true;

    // Reminder for you if you're modding a noteskin:
    // WHENEVER you change scale, or anything related to size,
    // Don't forget to update hitbox or else the sprites positions will look off! ^^
    receptor.updateHitbox();
}

function createStaticNote()
{
    staticNote.scale.set(scale, scale);
    staticNote.antialiasing = true;
}