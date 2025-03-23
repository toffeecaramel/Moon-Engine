package moon.game.obj;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import haxe.Json;
import flixel.ui.FlxBar;
import flixel.group.FlxSpriteGroup;

class HealthBar extends FlxSpriteGroup
{
    public var barBG:MoonSprite;
    public var bar:FlxBar;

    public var opponent(default, set):String;
    public var player(default, set):String;

    public var oppIcon:HealthIcon;
    public var playerIcon:HealthIcon;

    /**
     * The health ammount, which the healthbar tracks.
     */
    public var health(default, set):Float = 50;

    /**
     * Will create a health bar instance.
     * @param opponent the opponent name.
     * @param player the player name.
     */
    public function new(opponent:String, player:String)
    {
        super();

        barBG = cast new MoonSprite().loadGraphic(Paths.image('ingame/UI/healthbar'));
        barBG.scale.set(0.9, 0.9);
        barBG.updateHitbox();

        bar = new FlxBar(RIGHT_TO_LEFT, Std.int(barBG.width - 12), Std.int(barBG.height - 3));
        bar.x += 5;

        add(bar);
        add(barBG);

        oppIcon = new HealthIcon();
        oppIcon.scale.set(0.8, 0.8);
        oppIcon.y = bar.y - (oppIcon.height * 0.5);

        playerIcon = new HealthIcon();
        playerIcon.scale.set(0.8, 0.8);

        playerIcon.flipX = true;
        playerIcon.y = bar.y - (playerIcon.height * 0.5);

        add(oppIcon);
        add(playerIcon);

        this.opponent = opponent;
        this.player = player;

        bar.createFilledBar(getRGBData(opponent), getRGBData(player));
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        bar.value = FlxMath.lerp(bar.value, health, elapsed * 8);

        final percent:Float = 1 - (health / 100);
        final value = bar.x + (bar.width * percent);
        
        oppIcon.x = FlxMath.lerp(oppIcon.x, value - 100, elapsed * 8);
        playerIcon.x = FlxMath.lerp(playerIcon.x, value, elapsed * 8);

        //oppIcon.updateHitbox();
        //playerIcon.updateHitbox();
        oppIcon.scale.x = oppIcon.scale.y = playerIcon.scale.x = playerIcon.scale.y = FlxMath.lerp(playerIcon.scale.x, 0.8, elapsed * 12);

        oppIcon.y = bar.y - (oppIcon.height * 0.5);
        playerIcon.y = bar.y - (playerIcon.height * 0.5);
    }

    public function updateBarStats()
    {
        playerIcon.icon = player;
        oppIcon.icon = opponent;
    }

    public function getRGBData(character:String)
    {
        var data:Character.CharacterData = Paths.JSON('ingame/characters/${character}/data');
        final c = data.healthbarColors;
        return FlxColor.fromRGB(c[0], c[1], c[2]);
    }

    @:noCompletion public function set_opponent(val:String)
    {
        this.opponent = val;
        updateBarStats();
        return val;
    }

    @:noCompletion public function set_player(val:String)
    {
        this.player = val;
        updateBarStats();
        return val;
    }

    @:noCompletion public function set_health(ammount:Float)
    {
        this.health = ammount;
        playerIcon.updateAnim(ammount);
        oppIcon.updateAnim(100 - ammount);
        return ammount;
    }
}