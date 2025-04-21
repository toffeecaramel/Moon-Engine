package moon.game.obj.notes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import moon.dependency.MoonChart.NoteStruct; // We still need NoteStruct for input data
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteSpawner extends FlxGroup
{
    public var notes(default, null):Array<Note> = [];
    private var _notes:Array<Note> = [];

    private var strumlines:Array<Strumline> = [];

    public var scrollSpeed(default, set):Float = 1;

    private var nextNoteIndex:Int = 0;

    public function new(noteStructs:Array<NoteStruct>, strumlines:Array<Strumline>)
    {
        super();
        notes = _notes;
        this.strumlines = strumlines;

        for (noteStruct in noteStructs)
        {
            var note = createNoteFromStruct(noteStruct);
            if (note != null)
                _notes.push(note);
        }

        _notes.sort((a, b) ->  Std.int(a.time - b.time));
    }

    public var spawnThreshold:Float; 

    override public function update(dt:Float)
    {
        spawnThreshold = (scrollSpeed <= 0.9) ? 2000 : 700;
        super.update(dt);

        while (nextNoteIndex < _notes.length && (_notes[nextNoteIndex].time) <= Conductor.time + spawnThreshold)
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
                    note.speed = scrollSpeed;
                    note.state = NONE;
                    if(note.duration > 0) recycleSustain(note, group.sustainsGroup, note);
                    return note;
                });
            }
        }
    }

    public function recycleSustain(note:Note, group:FlxTypedSpriteGroup<NoteSustain>, parentNote:Note)
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
                var note = new Note(noteStruct.data, noteStruct.time,
                noteStruct.type, strum.receptors.members[noteStruct.data].skin, noteStruct.duration);

                note.speed = scrollSpeed;
                note.lane = noteStruct.lane;
                return note;
            }
        }
        return null;
    }

    @:noCompletion public function set_scrollSpeed(sp:Float)
    {
        this.scrollSpeed = sp / 2.4; // SÃO PAULO?!?!?!
        for (note in _notes)
            note.speed = sp;
        return sp; // SÃO PAULO VOLTOU VAMBORAAAAAAAAAAA
    }
}