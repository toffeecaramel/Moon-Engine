package moon.game.obj.notes;

import moon.dependency.MoonChart.NoteStruct;
import flixel.group.FlxGroup;

class NoteSpawner extends FlxGroup
{
    private var notes:Array<NoteStruct> = [];
    private var strumlines:Array<Strumline> = [];
    private var conductor:Conductor;
    
    // Keeps track of the next note to spawn. :3
    private var nextNoteIndex:Int = 0;
    
    public function new(notes:Array<NoteStruct>, strumlines:Array<Strumline>, conductor:Conductor)
    {
        super();
        this.notes = notes;
        this.strumlines = strumlines;
        this.conductor = conductor;
    
        notes.sort((a, b) ->  Std.int(a.time - b.time));
        
        // pre-spawn a few notes for recycling:
        for (i in 0...10)
        {
            if(i < notes.length) recycleNote(notes[i]);
        }
    }
    
    final spawnThreshold:Float = 700;
    
    override public function update(dt:Float)
    {
        super.update(dt);
        
        while (nextNoteIndex < notes.length && notes[nextNoteIndex].time <= conductor.time + spawnThreshold)
        {
            recycleNote(notes[nextNoteIndex]);
            nextNoteIndex++;
        }
    }
    
    public function recycleNote(data:NoteStruct)
    {
        for (strum in strumlines)
        {
            if (strum.strumID == data.lane)
            {
                final group = strum.receptors.members[data.data];
                group.notesGroup.recycle(Note, function():Note
                {
                    // TODO: Get note skin system.
                    var note = new Note(data.data, data.time, data.type, 'v-slice', data.duration, conductor);
                    note.receptor = strum.receptors.members[data.data];
                    note.visible = false;
                    if(note.duration > 0) recycleSustain(note, group.sustainsGroup);
                    return note;
                });
            }
        }
    }

    public function recycleSustain(note:Note, group:FlxTypedGroup<NoteSustain>)
    {
        group.recycle(NoteSustain, function():NoteSustain
        {
            var sustain = new NoteSustain(note);
            note.child = sustain;
            return sustain;
        });
    }
}
