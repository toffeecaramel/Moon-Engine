package moon.menus.obj.freeplay;

import flixel.tweens.FlxEase;
import flixel.addons.effects.FlxTrail;
import flixel.tweens.FlxTween;
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
    /**
     * The capsule sprite.
     */
    public var capsule:MoonSprite;

    /**
     * The text displayed with the song name.
     */
    public var text:MP3Text;

    /**
     * The icon displayed on the left of the capsule.
     */
    public var icon:PixelIcon;
    
    //TODO: Once implemented, get song's rank.
    /**
     * The rank displayed (if there's any).
     */
    public var rankDisplay:FreeplayRank;
    
    /**
     * The song's metadata, used for getting song's display name and other stuff.
     */
    public var meta:MetadataStruct;

    /**
     * The sparks that spawns when a new rank appears.
     */
    private var sparks:Array<MoonSprite> = [];

    /**
     * Whether is this capsule selected or not.
     */
    public var selected(default, set):Bool = false;

    /**
     * The rank for this Capsule.
     */
    public var rank:String;

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
        icon.setPosition(50, -20);
        icon.scale.set(2.3, 2.3);
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
        this.rank = rank;
        if(animated)
            for (spark in sparks)
            {
                spark.visible = true;
                spark.playAnim('miau', true);
                FlxG.camera.shake(0.03, 0.2);
            }

        rankDisplay.setRank(rank, true);

        if(rank != 'loss') doImpact();
    }

    public function confirm()
    {
        icon.playAnim('select', true);
        text.flickerText();    
    }

    public function doImpact()
    {
        var impact = new MoonSprite();
        impact.frames = capsule.frames;
        impact.frame = capsule.frame;
        impact.scale.set(0.8, 0.8);
        impact.alpha = 0.0001;
        add(impact);
        FlxTween.tween(impact.scale, {x: 2.5, y: 2.5}, 0.5);

        var trail = new FlxTrail(impact, null, 18, 2, 0.01, 0.069); //of course its 0.069
        trail.color = rankDisplay.getRankColor();
        trail.blend = ADD;
        add(trail);

        FlxTween.tween(trail, {alpha: 0}, 0.7, {ease: FlxEase.quadOut, onComplete: function(_) {
            trail.kill();
            impact.kill();
        }});
    }

    private var smoothing:Float = 1;
    public function shakeEffect(intensity:Float = 30)
    {
        smoothing = 1;
        new FlxTimer().start(0.015, function(_)
        {
            final value = (intensity * 4) / (smoothing / 3);
            follower.x += FlxG.random.float(-2 * value, 2 * value);
            follower.y += FlxG.random.float(-2 * value, 2 * value);
            smoothing++;
        }, 24);
    }

    override public function update(elapsed)
    {
        super.update(elapsed);
        this.setPosition(FlxMath.lerp(this.x, follower.x, 0.3), FlxMath.lerp(this.y, follower.y, 0.3));
    }

    @:noCompletion public function set_selected(selectedr:Bool):Bool
    {
        this.selected = selectedr;
        capsule.playAnim((selectedr) ? 'selected' : 'unselected');
        text.alpha = (selectedr) ? 1 : 0.4;
        return selectedr;
    }
}