package moon.backend.gameplay;

import moon.game.obj.notes.Note.NoteState;
import moon.game.obj.notes.*;
import moon.backend.gameplay.Timings;

/**
 * Class meant to handle note inputs in a gameplay scene.
 **/
class InputHandler
{
    public var stats:PlayerStats;
    public var playerID:String;
    public var strumline:Strumline;
    public var conductor:Conductor;

    private var heldSustains:Map<Int, Note> = new Map<Int, Note>();
    public var thisNotes:Array<Note> = [];

    public var onNoteHit:(Note, String, Bool)->Void;
    public var onNoteMiss:Note->Void;
    public var onGhostTap:Int->Void;
    public var onKeyRelease:Int->Void;
    public var onSustainComplete:Note->Void;

    public var justPressed:Array<Bool> = [];
    public var pressed:Array<Bool> = [];
    public var released:Array<Bool> = [];

    public function new(thisNotes:Array<Note>, playerID:String, strumline:Strumline, conductor:Conductor)
    {
        //TODO: Doccument this class.
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
        checkMisses();
    }

    private function processCPUInputs():Void
    {
        for (i in 0...4)
        {
            final possibleNotes = thisNotes.filter(note ->
            return (note.direction == i &&
                note.lane == playerID &&
                note.time - conductor.time <= 0 &&
                note.state == NONE)
            );

            possibleNotes.sort((a, b) -> Std.int(a.time - b.time));

            if (possibleNotes.length > 0)
                onHit(possibleNotes[0], i, 'sick', true);
        }
    }

    private function processInputs():Void
    {
        for (i in 0...justPressed.length)
        {
            if (justPressed[i])
            {
                final possibleNotes = thisNotes.filter(note ->
                return (note.direction == i &&
                    note.lane == playerID &&
                    isWithinTiming(note) &&
                    note.state == NONE)
                );

                possibleNotes.sort((a, b) -> Std.int(a.time - b.time));

                if (possibleNotes.length > 0)
                {
                    final note = possibleNotes[0];
                    final timing = checkTiming(note);

                    if (timing != null)
                    {
                        onHit(note, i, timing, false);
                        stats.totalNotes++;
                        stats.accuracyCount += Timings.getParameters(timing)[0];
                    }
                }
                else
                {
                    //TODO: Ghost tapping support, like, the options yea
                    if(onGhostTap != null) onGhostTap(i);
                    strumline.receptors.members[i].strumNote.playAnim('${MoonUtils.intToDir(i)}-press', true);
                    if (onNoteMiss != null/*&& !UserSettings.callSetting('Ghost Tapping')*/)
                    {
                        onNoteMiss(null);

                        stats.totalNotes++;
                        stats.accuracyCount += Timings.getParameters('miss')[0];
                    }
                }
            }
        }

        for (i in 0...released.length)
        {
            if(released[i])
            {
                if (onKeyRelease != null) onKeyRelease(i);
                strumline.receptors.members[i].strumNote.playAnim('${MoonUtils.intToDir(i)}-static', true);

                if (heldSustains.exists(i))
                {
                    strumline.receptors.members[i].sustainSplash.despawn(true);
                    final heldNote = heldSustains.get(i);
                    heldSustains.remove(i);

                    // Released early
                    if (heldNote != null && heldNote.state == GOT_HIT && heldNote.child != null)
                        heldNote.child.visible = heldNote.child.active = false;
                }
            }
        }
    }

    private function onHit(note:Note, ID:Int, timing:String, isCPU:Bool)
    {
        (timing != 'miss' && onNoteHit != null) ? onNoteHit(note, timing, isCPU) : (timing == 'miss' && onNoteMiss != null) ? onNoteMiss(note) : null;
        note.state = GOT_HIT;
        note.visible = note.active = false;
        strumline.receptors.members[note.direction].onNoteHit(note, timing, isCPU);
        strumline.receptors.members[note.direction].sustainSplash.despawn((playerID == 'opponent')); // just a workaround in case it doesnt stop
        if (note.duration > 0)
            heldSustains.set(ID, note);
    }

    private var sustainTrack:Int = 0; // for tracking sustain shii
    private function checkSustains():Void
    {
        for (direction in heldSustains.keys())
        {
            final heldNote = heldSustains.get(direction);
            if (heldNote != null && heldNote.state == GOT_HIT && heldNote.child != null && heldNote.child.active)
            {
                sustainTrack++;
                if(sustainTrack >= 5)
                {
                    (onNoteHit != null) ? onNoteHit(heldNote, null, true) : null;
                    strumline.receptors.members[heldNote.direction].onNoteHit(heldNote, null, true);
                    sustainTrack = 0;
                }

                if (conductor.time >= heldNote.time + heldNote.duration)
                {
                    heldNote.child.visible = heldNote.child.active = false;
                    heldSustains.remove(direction);
                }
            }
            else if (heldNote == null || heldNote.state != GOT_HIT || heldNote.child == null || !heldNote.child.active)
            {
                heldSustains.remove(direction);
                strumline.receptors.members[heldNote.direction].sustainSplash.despawn((playerID == 'opponent'));
                if(onSustainComplete != null) onSustainComplete(heldNote);
            }
        }
    }

    private function checkMisses():Void
    {
        for (note in thisNotes)
        {
            if (note.state != GOT_HIT && note.state != NoteState.TOO_LATE && note.lane == playerID && // Use playerID here for opponent misses too if needed
                conductor.time > note.time + Timings.getParameters('miss')[1])
            {
                if (onNoteMiss != null) onNoteMiss(note);
                note.state = TOO_LATE;
                note.visible = note.active = false;
                stats.accuracyCount += Timings.getParameters('miss')[0];
            }
        }
    }

    private function isWithinTiming(note:Note):Bool
        return checkTiming(note) != null;

    private function checkTiming(note:Note):String
    {
        final timeDifference = Math.abs(note.time - conductor.time);
        for (jt in Timings.values)
            if (timeDifference <= Timings.getParameters(jt)[1])
                return jt;
        return null;
    }
}