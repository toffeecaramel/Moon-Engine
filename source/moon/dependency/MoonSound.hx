package moon.dependency;

import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

enum MusicType {
    Inst;
    Voices_Player;
    Voices_Opponent;
}

typedef Metadata = {
    var displayName:String;
    var ?looped:Bool;
    var ?artist:String;
    var ?bpm:Float;
    var ?timeSignature:Array<Int>;
}

/**
 * This class basically is an extension of FlxSound, and
 * aims to add more utilities/functionalities to the already existing FlxSound;
 * Such as: pitch tween, pausing for a timer, and maybe more? who knows!
 * by @toffeecaramel
 **/
class MoonSound extends FlxSound
{
    // ----------- SONG DATA STUFF ----------- //

    /**
     * A metadata typedef, which contains important song INFO (if the file exists).
     */
    public var metadata:Metadata;

    /**
     * Used for recognizing whether the audio is inst or voices.
     */
    public var type:MusicType;

    /**
     * An string ID, used for some neat thingies.
     */
    public var strID:String;

    @:inheritDoc(FlxSound.loadEmbedded)
    override public function loadEmbedded(EmbeddedSound:FlxSoundAsset, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:() -> Void):MoonSound
        return cast super.loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);

    // ---------- TWEENS AND TIMERS ---------- //

    /**
     * Timer for the pause, used in `doBriefPause();`
     */
    private var _timer:FlxTimer;

    /**
     * Do a brief pause in the sound on a specific amount of time.
     * @param duration The duration of the pause.
     */
    public function doBriefPause( duration : Float = 0.0 ):Void
    {
        pause();

        if(_timer != null && _timer.active)
            _timer.cancel();

        _timer = new FlxTimer().start(duration, (_) -> play());
    }

    /**
     * Tween for the pitch tween, used in `pitchTween();`
     */
    private var _twn:FlxTween;

    /**
     * Tween the sound's pitch, if there's a pitch tween happening it will cancel it and start a new one.
     * @param toPitch      The pitch in which the sound will tween to.
     * @param duration     The duration of the tween.
     * @param easing       The easing of the tween.
     * @param completeFunc What happens after the tween completes.
     */
    public function pitchTween(toPitch : Float = 1, ?duration : Float = 1, 
    ?easing : EaseFunction, ?completeFunc : Void->Void)
    {
        if(_twn != null && _twn.active)
            _twn.cancel();

        _twn = FlxTween.tween(this, {pitch: toPitch}, duration, 
            {ease: (easing == null) ? FlxEase.linear : easing, onComplete: (_) -> (completeFunc != null) ? completeFunc() : null});
    }
}