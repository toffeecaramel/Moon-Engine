package moon.game.obj.notes;

import moon.dependency.MoonChart.NoteStruct; // We still need NoteStruct for input data
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteSpawner extends FlxGroup
{
    public var notes(default, null):Array<Note> = [];
    private var _notes:Array<Note> = [];

    private var strumlines:Array<Strumline> = [];
    private var conductor:Conductor;

    // Keeps track of the next note to spawn. :3
    private var nextNoteIndex:Int = 0;

    public function new(noteStructs:Array<NoteStruct>, strumlines:Array<Strumline>, conductor:Conductor)
    {
        super();
        notes = _notes;
        this.strumlines = strumlines;
        this.conductor = conductor;

        for (noteStruct in noteStructs)
        {
            var note = createNoteFromStruct(noteStruct);
            if (note != null)
                _notes.push(note);
        }

        _notes.sort((a, b) ->  Std.int(a.time - b.time));

        for (i in 0...15)
            recycleNote(_notes[i]);
    }

    final spawnThreshold:Float = 700;

    override public function update(dt:Float)
    {
        super.update(dt);

        while (nextNoteIndex < _notes.length && _notes[nextNoteIndex].time <= conductor.time + spawnThreshold)
        {
            recycleNote(_notes[nextNoteIndex]);
            nextNoteIndex++;
        }
    }

    public function recycleNote(note:Note)
    {
        for (strum in strumlines)
        {
            if (strum.playerID == note.lane)
            {
                final group = strum.receptors.members[note.direction];
                group.notesGroup.recycle(Note, function():Note
                {
                    note.receptor = strum.receptors.members[note.direction];
                    note.visible = false;
                    note.state = NONE;
                    if(note.duration > 0) recycleSustain(note, group.sustainsGroup, note);
                    return note;
                });
            }
        }
    }

    public function recycleSustain(note:Note, group:FlxTypedGroup<NoteSustain>, parentNote:Note)
    {
        group.recycle(NoteSustain, function():NoteSustain
        {
            var sustain = note.child != null ? note.child : new NoteSustain(parentNote);
            if (note.child == null) note.child = sustain;
            return sustain;
        });
    }


    private function createNoteFromStruct(noteStruct:NoteStruct):Note
    {
        for (strum in strumlines)
        {
            if (strum.playerID == noteStruct.lane)
            {
                // TODO: Get note skin system.
                var note = new Note(noteStruct.data, noteStruct.time, noteStruct.type, 'v-slice', noteStruct.duration, conductor);
                note.lane = noteStruct.lane;
                return note;
            }
        }
        return null;
    }
}