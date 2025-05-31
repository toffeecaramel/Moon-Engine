package moon.toolkit.level_editor;

import moon.backend.gameplay.InputHandler;
import flixel.util.FlxColor;
import flixel.FlxG;
import moon.game.obj.notes.Strumline;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class Miniplayer extends FlxSpriteGroup
{
    public function new(?x:Float = 0, ?y:Float = 0, chartEditor:LevelEditor)
    {
        super(x, y);
        var back = new MoonSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(back);

        final xVal = (FlxG.width * 0.5);
        final xAddition = (FlxG.width * 0.25);
        final strumXs = [-xAddition, xAddition];
		
        final playerIDs = ["opponent", "p1"];

        for (i in 0...playerIDs.length)
        {
            //TODO: Skins lol
            var strumline = new Strumline(xVal + strumXs[i], 68, 'mooncharter', false, playerIDs[i], chartEditor.conductor);
            add(strumline);

            for(receptor in strumline.members)
            {
                add(receptor.sustainsGroup);
                add(receptor.notesGroup);
                add(receptor.splashGroup);
            }

            var inputHandler = new InputHandler(null, playerIDs[i], strumline, chartEditor.conductor);
			inputHandler.CPUMode = true;

            //p1Judgements.skin = p1Combo.skin = strumline.members[0].judgementsSkin;
        }
    }
}