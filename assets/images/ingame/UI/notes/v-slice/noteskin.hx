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

    splash.scale.set(0.8, 0.8);
    splash.antialiasing = true;
}

function createStaticNote()
{
    staticNote.scale.set(scale, scale);
    staticNote.antialiasing = true;
}