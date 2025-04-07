package moon.menus.obj.freeplay;

import flixel.group.FlxSpriteGroup;
import moon.backend.Paths;

class FreeplayRank extends FlxSpriteGroup
{
    public var rankSprite:MoonSprite;
    
    public function new(?x:Float = 410, ?y:Float = 42)
    {
        super(x, y);
        rankSprite = new MoonSprite(0, 0);
        rankSprite.frames = Paths.getSparrowAtlas("menus/freeplay/rankbadges");

        rankSprite.animation.addByPrefix("loss", "LOSS rank0", 24, false);
        rankSprite.animation.addByPrefix("good", "GOOD rank0", 24, false);
        rankSprite.animation.addByPrefix("great", "GREAT rank0", 24, false);
        rankSprite.animation.addByPrefix("excellent", "EXCELLENT rank0", 24, false);
        rankSprite.animation.addByPrefix("perfect", "PERFECT rank0", 24, false);
        rankSprite.animation.addByPrefix("perfectGold", "PERFECT rank GOLD0", 24, false);

        rankSprite.addOffset("loss", -3, 4);
        rankSprite.addOffset("good", 0, 4);
        rankSprite.addOffset("great", 0, 3);
        rankSprite.addOffset("excellent", -2, 4);
        rankSprite.addOffset("perfect", 0, 2);
        rankSprite.addOffset("perfectGold", 0, 2);
        rankSprite.playAnim("perfectGold");

        rankSprite.visible = false;
        rankSprite.antialiasing = true;

        add(rankSprite);
    }
    
    public function playRank(animName:String, force:Bool = false):Void
    {
        rankSprite.playAnim(animName, force);
        rankSprite.visible = true;
    }
}
