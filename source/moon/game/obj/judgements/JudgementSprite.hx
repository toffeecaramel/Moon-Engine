package moon.game.obj.judgements;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

@:publicFields
class JudgementSprite extends MoonSprite
{
    /**
     * The judgement's skin display.
     */
    var skin(default, set):String = '';

     /**
      * All the data for this.
      */
    var data:JudgementsJSON;

    var yTwn:FlxTween;
    var fadeTwn:FlxTween;

    /**
     * Displays the judgement on screen
     * @param judgement The judgement name
     * @param animate Whether it should do a 'jump' animation or not.
     * @param fade Whether it should do a fade out or not.
     */
    function showJudgement(judgement:String = 'sick', animate:Bool = true, fade:Bool = true)
    {
        if(this.alpha <= 1) this.alpha = 1;
        this.loadGraphic(Paths.image('ingame/UI/judgements_combo/$skin/$judgement'));
        this.antialiasing = data?.antialiasing ?? true;
        this.scale.set(data?.judgementScale ?? 1, data?.judgementScale ?? 1);
        this.updateHitbox();

        if(fadeTwn != null && fadeTwn.active) fadeTwn.cancel();

        if(animate)
        {
            if(yTwn != null && yTwn.active) yTwn.cancel();
            this.y -= 25;
            yTwn = FlxTween.tween(this, {y:this.y + 25}, 0.24, {ease: FlxEase.quadOut});
        }

        if(fade)
            fadeTwn = FlxTween.tween(this, {alpha: 0}, 0.4, {startDelay: 0.6});
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;

        if(Paths.fileExists('assets/images/ingame/UI/judgements_combo/$skin/config.json'))
            data = Paths.JSON('ingame/UI/judgements_combo/$skin/config');

        return this.skin;
    }
}