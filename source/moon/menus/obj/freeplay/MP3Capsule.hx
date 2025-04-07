package moon.menus.obj.freeplay;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.FlxBasic;
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
    public var rankDisplay:FreeplayRank;

    private var sparks:Array<MoonSprite> = [];

    public var selected(default, set):Bool = false;

    public var meta:MetadataStruct;

    /**
     * Used for setting the mp3 position.
     * If you want to change this MP3's position on screen, change this follower position instead.
     */
    public var follower:FlxObject = new FlxObject();


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

        text = new MP3Text(162, 44, meta.displayName, 32);
        add(text);

        icon = new PixelIcon(meta.opponents[0]);
        icon.updateHitbox();
        icon.setPosition(10, -40);
        icon.scale.x -= 0.2;
        icon.scale.y -= 0.2;
        add(icon);

        rankDisplay = new FreeplayRank();
        add(rankDisplay);

        final b = [180, -160];
        var spark = new MoonSprite(b[0], b[1]);
        spark.frames = Paths.getSparrowAtlas('menus/freeplay/sparks');
        spark.animation.addByPrefix('miau', 'sparks', 24, false);
        spark.scale.set(0.6, 0.6);
        spark.animation.onFinish.add((_) -> spark.visible = false);
        spark.visible = false;
        spark.centerAnimations = true;
        add(spark);
        sparks.push(spark);

        var sparkadd = new MoonSprite(b[0], b[1]);
        sparkadd.frames = Paths.getSparrowAtlas('menus/freeplay/sparksadd');
        sparkadd.animation.addByPrefix('miau', 'sparks add', 24, false);
        sparkadd.animation.onFinish.add((_) -> sparkadd.visible = false);
        sparkadd.visible = false;
        sparkadd.blend = ADD;
        sparkadd.scale.set(spark.scale.x, spark.scale.y);
        sparkadd.centerAnimations = true;
        add(sparkadd);
        sparks.push(sparkadd);
    }

    /**
     * Set a rank for this MP3 Player's song
     * @param rank The rank to be displayed.
     * @param animated Whether or not to play an animation for it.
     */
    public function setRank(rank:String, animated:Bool = false)
    {
        if(animated)
            for (spark in sparks)
            {
                spark.visible = true;
                spark.playAnim('miau', true);
            }

        rankDisplay.playRank(rank, true);
    }

    public function shakeEffect(intensity:Float = 30)
    {
        new FlxTimer().start(0.03, function(_)
        {
            follower.x = follower.x + FlxG.random.float(-5 * intensity, 5 * intensity);
            follower.y = follower.y + FlxG.random.float(-5 * intensity, 5 * intensity);
        }, 8);
    }

    override public function update(elapsed)
    {
        super.update(elapsed);
        this.setPosition(FlxMath.lerp(this.x, follower.x, 0.3), FlxMath.lerp(this.y, follower.y, 0.3));

        for(blegh in this.members)
            blegh.active = (blegh.visible || blegh.alpha >= 0.1); //kinda makes it more optimized-ish
    }

    @:noCompletion public function set_selected(selectedr:Bool):Bool
    {
        this.selected = selectedr;
        capsule.playAnim((selectedr) ? 'selected' : 'unselected');
        text.alpha = (selectedr) ? 1 : 0.4;
        return selectedr;
    }
}