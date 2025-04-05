package moon.menus.obj.freeplay;

import moon.global_obj.PixelIcon;
import moon.dependency.MoonChart.MetadataStruct;
import flixel.group.FlxSpriteGroup;

/**
 * MP3 Capsule Used in a song list for Freeplay.
 */
class MP3Capsule extends FlxSpriteGroup
{
    public var capsule:MoonSprite;
    public var text:MP3Text;
    public var icon:PixelIcon;

    public var selected(default, set):Bool = false;

    public var meta:MetadataStruct;

    /**
     * Creates a MP3 Capsule.
     * @param x X Position
     * @param y Position
     * @param character Character name (for getting capsule colors, and color for its text as well.)
     * @param songName The name of the song in which will be displayed.
     * @param meta The song's metadata.
     */
    public function new(?x:Float = 0, ?y:Float = 0, character:String = 'bf', 
        meta:MetadataStruct)
    {
        super(x, y);
        this.meta = meta;

        capsule = new MoonSprite();
        capsule.frames = Paths.getSparrowAtlas('menus/freeplay/$character/capsule');
        capsule.animation.addByPrefix('selected', 'mp3 capsule w backing0', 24, true);
        capsule.animation.addByPrefix('unselected', 'mp3 capsule w backing NOT SELECTED0', 24, true);
        capsule.scale.set(0.8, 0.8);
        capsule.playAnim('unselected');
        capsule.centerAnimations = true;
        add(capsule);

        text = new MP3Text(164, 44, meta.displayName + 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', 32);
        add(text);

        icon = new PixelIcon(character);
        icon.updateHitbox();
        icon.setPosition(10, -40);
        icon.scale.x -= 0.2;
        icon.scale.y -= 0.2;
        add(icon);
    }

    @:noCompletion public function set_selected(selectedr:Bool):Bool
    {
        this.selected = selectedr;
        capsule.playAnim((selectedr) ? 'selected' : 'unselected');
        text.alpha = (selectedr) ? 1 : 0.4;
        return selectedr;
    }
}