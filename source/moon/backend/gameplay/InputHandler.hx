package moon.backend.gameplay;

import moon.game.obj.notes.Note.NoteState;
import moon.game.obj.notes.*;
import moon.backend.gameplay.Timings;

/**
 * Class meant to handle note inputs in a gameplay scene.
 **/
class InputHandler
{
    public var onNoteHit:(Note, String, Bool)->Void;
    public var onNoteMiss:Note->Void;
    public var onGhostTap:Int->Void;
    public var onKeyRelease:Int->Void;

    public var justPressed:Array<Bool> = [];
    public var pressed:Array<Bool> = [];
    public var released:Array<Bool> = [];

    public var playerID:String;
    private var conductor:Conductor;
    
    private var heldSustains:Map<Int, Note> = new Map<Int, Note>();
    public var thisNotes:Array<Note> = [];

    public function new(thisNotes:Array<Note>, playerID:String, conductor:Conductor)
    {
        //TODO: Doccument this class.
        this.thisNotes = thisNotes;
        this.playerID = playerID;
        this.conductor = conductor;
    }

    public function update():Void
    {
        if(playerID != 'opponent')
        {
            processInputs();
            checkSustains();
            checkMisses();
        }
    }

    private function processInputs():Void
    {
        for (i in 0...justPressed.length)
        {
            if (justPressed[i])
            {
                var possibleNotes = thisNotes.filter(note ->
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
                        (timing != 'miss' && onNoteHit != null) ? onNoteHit(note, timing, false) : (timing == 'miss' && onNoteMiss != null) ? onNoteMiss(note) : null;
                        note.state = GOT_HIT;
                        if (note.duration > 0)
                            heldSustains.set(i, note);
                        note.visible = note.active = false;
                    }
                }
                else
                {
                    if(onGhostTap != null) onGhostTap(i);
                    if (onNoteMiss != null/*&& !UserSettings.callSetting('Ghost Tapping')*/)
                        onNoteMiss(null);
                }
            }
        }

        for (i in 0...released.length)
        {
            if(released[i])
            {
                if (onKeyRelease != null) onKeyRelease(i);

                if (heldSustains.exists(i))
                {
                    final heldNote = heldSustains.get(i);
                    heldSustains.remove(i);

                    // Released early
                    if (heldNote != null && heldNote.state == GOT_HIT && heldNote.child != null)
                        heldNote.child.visible = heldNote.child.active = false;
                }
            }
        }
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
                    sustainTrack = 0;
                }

                if (conductor.time >= heldNote.time + heldNote.duration)
                {
                    heldNote.child.visible = heldNote.child.active = false;
                    heldSustains.remove(direction);
                }
            }
            else if (heldNote == null || heldNote.state != GOT_HIT || heldNote.child == null || !heldNote.child.active)
                heldSustains.remove(direction);
        }
    }

    private function checkMisses():Void
    {
        for (note in thisNotes)
        {
            if (note.state != GOT_HIT && note.state != TOO_LATE && note.lane == 'p1' &&
                conductor.time > note.time + Timings.getParameters('miss')[1])
            {
                if (onNoteMiss != null) onNoteMiss(note);
                note.state = TOO_LATE;
                note.visible = note.active = false;
                //TODO This :3 v
                //playerStats.SCORE += Std.int(Timings.getParameters('miss')[2]);
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