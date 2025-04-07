package moon.menus.obj.freeplay;

import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class AlbumCollection extends FlxSpriteGroup
{
    private var albumSprites:Array<MoonSprite>;
    public var ringRotation:Float = 0;

    private var baseAngle:Float = 0;
    private var angleStep:Float = Math.PI / 4;

    private final radiusX:Float = 65;
    private final radiusY:Float = 50;

    private final minScale:Float = 0.4;
    private final maxScale:Float = 1;

    // Load album names from a text file.
    final albumList = MoonUtils.getArrayFromFile(Paths.getPath("images/menus/freeplay/albums/albumlist.txt", TEXT));

    public function new(?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);
        albumSprites = [];

        for (i in 0...albumList.length)
        {
            // setup the album sproite
            this.recycle(MoonSprite, function():MoonSprite
            {
                var sprite = new MoonSprite();
                sprite.loadGraphic(Paths.image('menus/freeplay/albums/${albumList[i]}'));
                sprite.updateHitbox();
                sprite.strID = albumList[i];
                albumSprites.push(sprite);
                return sprite;
            });
        }

        // adjust angleStep to spread albums over some kindof horizontal range (like PI for semi-circle or smth)
        if(albumSprites.length > 1) angleStep = (Math.PI * 0.9) / (albumSprites.length - 1);
        else angleStep = 0;

        repositionItems();
    }

    public var currentAlbum:String = 'placeholder';

    /**
     * Switches to a given album by name.
     * It rotates the ring so that the specified album's angle becomes 0 (centered)
     * and then brings that album to the front.
     * @param albumName The name of the album.
     */
    public function switchToAlbum(albumName:String):Void
    {
        if(!albumList.contains(albumName)) albumName = 'placeholder'; //just a little handler.
        for (i in 0...albumSprites.length)
        {
            var album = albumSprites[i];
            if(album.strID == albumName)
            {
                // remove then add it so it stays on front
                currentAlbum = album.strID;
                new FlxTimer().start(0.03, function(_)
                {
                    remove(album, true);
                    add(album);
                });
            }
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        for (i in 0...albumSprites.length)
            if(albumSprites[i].strID == currentAlbum)
                ringRotation = FlxMath.lerp(ringRotation, -(baseAngle + i * angleStep), 0.3);

        repositionItems();
    }

    private function repositionItems():Void
    {
        // I am DEAD serious when I say this: I had to use AI HELP for this math
        // cause I FUCKING SUCK at math, genuinely.
        // I do not say this proudly. go learn math. dont be like me.
        // lauro is the one who made the concept for this LAURO I HATE YOUUU FOR THAT ONE </3
        // but this looks pretty so thanks either way <3
        for (i in 0...albumSprites.length)
        {
            final album:MoonSprite = albumSprites[i];
            final angle:Float = baseAngle + i * angleStep + ringRotation;

            // calculate horizontal position
            album.x = this.x + Math.cos(angle) * radiusX - album.width * 0.5;

            // calculate vertical position
            album.y = this.y + Math.sin(angle) * radiusY - album.height * 0.5;

            // Some stuff so when they're distant they look cooler
            final distanceFactor:Float = (Math.cos(angle) + 1) / 2;
            final scaleFactor:Float = minScale + (maxScale - minScale) * distanceFactor;
            album.scale.set(scaleFactor, scaleFactor);
            //album.alpha = 0.4 + 0.6 * distanceFactor;

            // interpolate the colors so the distant ones become black-ish
            final desaturationFactor:Float = 1 - distanceFactor;
            final desaturatedColor:FlxColor = FlxColor.interpolate(FlxColor.WHITE, FlxColor.GRAY, desaturationFactor);
            final blackishColor:FlxColor = FlxColor.interpolate(desaturatedColor, FlxColor.BLACK, desaturationFactor * 0.6);
            album.color = blackishColor;
        }
    }
}