function onCreate()
{
    dj.loadAtlas(Paths.getPath("images/menus/freeplay/bf/freeplay-bf", null));
    dj.anim.addBySymbol("intro", "boyfriend dj intro", 24, false);
    dj.anim.addBySymbol("idle", "Boyfriend DJ", 24, false);
    dj.anim.addBySymbol("loss", "Boyfriend DJ loss reaction 1", 24, false);
    dj.anim.play("loss", true);
    dj.screenCenter();
    dj.x += 128;
    dj.y += 65;
}

function onUpdate(elapsed)
{

}