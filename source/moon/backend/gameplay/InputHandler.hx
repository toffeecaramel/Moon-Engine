package moon.backend.gameplay;

import moon.game.obj.notes.Note.NoteState;
import moon.game.obj.notes.*;
import moon.backend.gameplay.Timings;

/**
 * Class meant to handle note inputs in a gameplay scene.
 **/
class InputHandler
{
    /**
     * Playerstats used in here.
     * TODO: make a better description for this ;V
     */
    public var stats:PlayerStats;

    /**
     * The player ID, used for many things, but mainly note reading and inputs.
     */
    public var playerID:String;

    /**
     * The strumline, used for triggering animations and maybe more.
     */
    public var strumline:Strumline;

    /**
     * The conductor class, used for many things among with note timings.
     */
    public var conductor:Conductor;

    /**
     * Map for the sustain notes.
     */
    private var heldSustains:Map<Int, Note> = new Map<Int, Note>();

    /**
     * Array for the notes in this class, needed for reading their timings and such.
     */
    public var thisNotes:Array<Note> = [];

    /**
     * Function called whenever a note gets hit (Good Hit.)
     */
    public var onNoteHit:(Note, String, Bool)->Void;

    /**
     * Function called whenever a note is missed (Bad Hit.)
     */
    public var onNoteMiss:Note->Void;
    
    /**
     * Function called whenever a key is pressed (if ghost tapping is off, it'll call onNoteMiss right after.)
     */
    public var onGhostTap:Int->Void;

    /**
     * Function called whenever a key is released.
     */
    public var onKeyRelease:Int->Void;

    /**
     * Function called whenever a sustain gets completed (held till the end.)
     */
    public var onSustainComplete:Note->Void;

    /**
     * Array for all the the keys on the 'justPressed' state.
     */
    public var justPressed:Array<Bool> = [];

    /**
     * Array for all the the keys on the 'pressed' state.
     */
    public var pressed:Array<Bool> = [];

    /**
     * Array for all the the keys on the 'released' state.
     */
    public var released:Array<Bool> = [];

    /**
     * Creates input handler instance, all this does is handling inputs for a player you choose.
     * @param thisNotes The notes array that it will read.
     * @param playerID  The ID for the player. currently supported are [`opponent, p1`]
     * @param strumline The strumline, used for triggering animations on it.
     * @param conductor The conductor instance, used for many things.
     */
    public function new(thisNotes:Array<Note>, playerID:String, strumline:Strumline, conductor:Conductor)
    {
        this.thisNotes = thisNotes;
        this.playerID = playerID;
        this.strumline = strumline;
        this.conductor = conductor;
        this.stats = new PlayerStats(playerID);
    }

    public function update():Void
    {
        if(playerID != 'opponent')
            processInputs();
        else
            processCPUInputs();

        checkSustains();
        onLateMiss();
    }

    private function processCPUInputs():Void
    {
        for (i in 0...4)
        {
            // get the possible notes thats in the... perfect timing
            final possibleNotes = thisNotes.filter(note ->
            return (note.direction == i &&
                note.lane == playerID &&
                note.time - conductor.time <= 0 &&
                note.state == NONE)
            );

            // sort them bc why not :P
            possibleNotes.sort((a, b) -> Std.int(a.time - b.time));

            // then call onhit
            if (possibleNotes.length > 0)
                onHit(possibleNotes[0], i, 'sick', true);
        }
    }

    private function processInputs():Void
    {
        // now, since this is for player's inputs and needs to have timing, it'll be a lil more complex.
        for (i in 0...justPressed.length)
        {
            // iterates through the keys and checks if any of them got pressed.
            if (justPressed[i])
            {
                // now filter through the possible notes to hit, matching its current time to the next available judgement
                final possibleNotes = thisNotes.filter(note ->
                return (note.direction == i &&
                    note.lane == playerID &&
                    isWithinTiming(note) &&
                    note.state == NONE)
                );

                // then sort through notes or else timings will act weird-ish
                possibleNotes.sort((a, b) -> Std.int(a.time - b.time));

                if (possibleNotes.length > 0)
                {
                    // and then finally call on hit for the notes
                    final note = possibleNotes[0];
                    final timing = checkTiming(note);

                    if (timing != null)
                    {
                        onHit(note, i, timing, false);
                        stats.totalNotes++;
                        stats.accuracyCount += Timings.getParameters(timing)[0];
                    }
                }
                else // and this is called when you ghost tap.
                {
                    //TODO: Ghost tapping support, like, the options yea
                    if(onGhostTap != null) onGhostTap(i);
                    strumline.receptors.members[i].strumNote.playAnim('${MoonUtils.intToDir(i)}-press', true);
                    if (onNoteMiss != null/*&& !UserSettings.callSetting('Ghost Tapping')*/)
                    {
                        onNoteMiss(null);
                        stats.misses++;
                        stats.score += Timings.getParameters('miss')[2];

                        stats.totalNotes++;
                        stats.accuracyCount += Timings.getParameters('miss')[0];
                    }
                }
            }
        }

        // iterate through every released key
        for (i in 0...released.length)
        {
            if(released[i])
            {
                // call on release if a released key is detected (like that one vs hex song yes its defnitely a reference hahaha laugh now.)
                if (onKeyRelease != null) onKeyRelease(i);
                strumline.receptors.members[i].strumNote.playAnim('${MoonUtils.intToDir(i)}-static', true);

                // now all this does is check if a key got released early while holding a sustain
                // then 'kill' it (not necessarily kill. we dont kill notes around here...)
                if (heldSustains.exists(i))
                {
                    strumline.receptors.members[i].sustainSplash.despawn(true);
                    final heldNote = heldSustains.get(i);
                    heldSustains.remove(i);

                    if (heldNote != null && heldNote.state == GOT_HIT && heldNote.child != null)
                        heldNote.child.visible = heldNote.child.active = false;
                }
            }
        }
    }

    private function onHit(note:Note, ID:Int, timing:String, isCPU:Bool)
    {
        // kind of a big one line if statement but les go I'll explain nice n slow :3
        // first of all, it checks if the timing is not a miss and the callback to 'onNoteHit' isnt null
        // then it'll call onNoteHit.
        // else if timing is equal miss and onNoteMiss' callback is not null
        // it'll call onNoteMiss
        (timing != 'miss' && onNoteHit != null) ? onNoteHit(note, timing, isCPU) : (timing == 'miss' && onNoteMiss != null) ? onNoteMiss(note) : null;
        if(timing == 'miss') stats.misses++;
        // do some changes on the note after it gets hit
        note.state = GOT_HIT;
        note.visible = note.active = false;

        stats.score += Timings.getParameters(timing)[2];

        // call strumline stuff
        strumline.receptors.members[note.direction].onNoteHit(note, timing, isCPU);
        strumline.receptors.members[note.direction].sustainSplash.despawn((playerID == 'opponent')); // just a workaround in case it doesnt stop

        // set the sustain if it exists
        if (note.duration > 0)
            heldSustains.set(ID, note);
    }

    private var sustainTrack:Int = 0; // for tracking sustain stuffies
    private function checkSustains():Void
    {
        for (direction in heldSustains.keys())
        {
            final heldNote = heldSustains.get(direction);
            // on hold note hit
            if (heldNote != null && heldNote.state == GOT_HIT && heldNote.child != null && heldNote.child.active)
            {
                // basically the ticks ammount when to call an sustain note hit
                sustainTrack++;
                if(sustainTrack % 6 == 0)
                {
                    (onNoteHit != null) ? onNoteHit(heldNote, null, true) : null;
                    stats.score += 2;
                    strumline.receptors.members[heldNote.direction].onNoteHit(heldNote, null, true);
                }

                if (conductor.time >= heldNote.time + heldNote.duration)
                {
                    heldNote.child.visible = heldNote.child.active = false;
                    heldSustains.remove(direction);
                }
            }
            // on sustain note complete, basically, when you hold it till the end.
            else if (heldNote == null || heldNote.state != GOT_HIT || heldNote.child == null || !heldNote.child.active)
            {
                heldSustains.remove(direction);
                strumline.receptors.members[heldNote.direction].sustainSplash.despawn((playerID == 'opponent'));
                if(onSustainComplete != null) onSustainComplete(heldNote);
            }
        }
    }

    private function onLateMiss():Void
    {
        // iterates through all notes and checks if they're too late.
        for (note in thisNotes)
        {
            if (note.state != GOT_HIT && note.state != NoteState.TOO_LATE && note.lane == playerID &&
                conductor.time > note.time + Timings.getParameters('miss')[1])
            {
                if (onNoteMiss != null) onNoteMiss(note);
                note.state = TOO_LATE;
                note.visible = note.active = false;
                stats.accuracyCount += Timings.getParameters('miss')[0];
                stats.score += Timings.getParameters('miss')[2];
                stats.misses++;
            }
        }
    }

    /**
     * Checks if the note is within timing,
     * @param note 
     * @return Bool
        return checkTiming(note) != null
     */
    private function isWithinTiming(note:Note):Bool
        return checkTiming(note) != null;

    /**
     * Checks the timing for a note, then it'll return its appropriate judgement.
     * @param note 
     * @return String
     */
    private function checkTiming(note:Note):String
    {
        final timeDifference = Math.abs(note.time - conductor.time);
        for (jt in Timings.values)
            if (timeDifference <= Timings.getParameters(jt)[1])
                return jt;

        return null;
    }
}