function onCreate()
    {
        dj.loadAtlas(Paths.getPath("images/menus/freeplay/bf/freeplay-bf", null));
        
        // Main Anims
        dj.anim.addBySymbol("intro", "boyfriend dj intro", 24, false);
        dj.anim.addBySymbol("idle", "bf chilling", 24, true);
        dj.anim.addBySymbol("newChar", "Boyfriend DJ new character", 24, true);
        dj.anim.addBySymbol("confirm", "Boyfriend DJ confirm", 24, false);
        dj.anim.addBySymbol("leave", "Boyfriend DJ to CS", 24, false);
    
        // Rank Anims
        dj.anim.addBySymbol("rankWin", "Boyfriend DJ fist pump", 24, false);
        dj.anim.addBySymbol("rankLoss", "Boyfriend DJ loss reaction 1", 24, false);
    
        // Extra
        dj.anim.addBySymbol("afk1", "bf dj afk", 24, false);
        dj.anim.addBySymbol("afk2", "Boyfriend DJ watchin tv OG", 24, true);
    
        dj.anim.play("idle", true);
        dj.screenCenter();
        dj.antialiasing = true;
        dj.x += 420;
        dj.y += 670;
    }
    
    function onUpdate(elapsed)
    {
    
    }