final scale = 0.6;

function createStrumNote()
{
    //trace("Hello there! From noteskin~", "DEBUG");

    // Rescale the note cause its big af
    receptor.scale.set(scale, scale);

    // Set the antialiasing to true otherwise it looks weird
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

function createSplash()
{
    splash.scale.set(0.8, 0.8);
    splash.antialiasing = true;
}