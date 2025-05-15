import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import moon.dependency.scripting.MoonEvent;
import flixel.util.FlxTimer;
import moon.dependency.MoonUtils;

function onCutsceneStart()
{
    game.camHUD.visible = false;
    MoonUtils.playGlobalMusic('game/weeb/Lunchbox', true);

    game.onHardcodedEvent(new MoonEvent('SetCameraFocus', null).getCamFocusValues('opponent', 1, "circOut"));
    new FlxTimer().start(1.8, (_) -> {
        FlxG.sound.play(Paths.sound('game/cutscenes/test/senpai-aa', 'sounds'));
        charAnim('opponent', 'singUP');

        new FlxTimer().start(0.7, (_) -> {

            charAnim('opponent', 'idle-0');
            game.onHardcodedEvent(new MoonEvent('SetCameraFocus', null).getCamFocusValues('player', 2, "expoOut"));

            new FlxTimer().start(0.2, (_) -> {

                FlxG.sound.play(Paths.sound('game/cutscenes/test/boingreverse', 'sounds'));
                game.onHardcodedEvent(new MoonEvent('SetCameraZoom', null).getCamZoomValues(2, 1.82, "cubicIn"));

                FlxTween.tween(game.stage.players.members[0], {"scale.x": 10, "scale.y": 3}, 1.82, {ease: FlxEase.quadIn, onComplete: (_) -> {
                    
                    FlxG.sound.play(Paths.sound('game/cutscenes/test/boing', 'sounds'));
                    FlxG.sound.play(Paths.sound('game/cutscenes/test/bf-ee', 'sounds'));
                    charAnim('player', 'singRIGHT');

                    game.onHardcodedEvent(new MoonEvent('SetCameraZoom', null).getCamZoomValues(1, 0.4, "cubicOut"));

                    FlxTween.tween(game.stage.players.members[0], {"scale.x": 6, "scale.y": 6}, 1, {ease: FlxEase.elasticOut, onComplete: (_) -> {
                        charAnim('player', 'idle-0');

                        game.onHardcodedEvent(new MoonEvent('SetCameraFocus', null).getCamFocusValues('opponent', 0.0001, "expoOut"));
                        FlxG.sound.music.stop();
                        new FlxTimer().start(1, (_) -> 
                        {
                            game.onHardcodedEvent(new MoonEvent('SetCameraFocus', null).getCamFocusValues('player', 0.0001, "expoOut"));

                            FlxG.sound.play(Paths.sound('game/cutscenes/test/lesgo', 'sounds'));
                            charAnim('player', 'singLEFT');

                            new FlxTimer().start(0.42, (_) -> {
                                charAnim('player', 'singRIGHT');

                                playField.inCutscene = false;
                                game.camHUD.visible = true;
                            });
                        });
                    }});
                }});
            });
        });
    });
}

function charAnim(who:String, anim:String)
{
    switch(who)
    {
        case 'opponent': game.stage.opponents.members[0].playAnim(anim, true);
        default: game.stage.players.members[0].playAnim(anim, true);
    }
}