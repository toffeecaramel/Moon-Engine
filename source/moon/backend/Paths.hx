package moon.backend;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.sound.FlxSound;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;

using StringTools;

/**
 * The Paths class, used for getting ingame files and memory cleaning as well.
 * 
 * Would like to clarify that: This class belongs to Doido Engine, and I'm using it with permission.
 * https://github.com/DoidoTeam/FNF-Doido-Engine/blob/main/source/Paths.hx
 * (Give Doido Engine a try, It's a very well made engine! ^^)
 **/
class Paths
{
    public static var renderedGraphics:Map<String, FlxGraphic> = [];
    public static var renderedSounds:Map<String, Sound> = [];

    // idk
    public static function getPath(key:String, ?library:String):String
    {
        #if RENAME_UNDERSCORE
        var pathArray:Array<String> = key.split("/").copy();
        var loopCount = 0;
        key = "";

        for (folder in pathArray)
        {
            var truFolder:String = folder;

            if(folder.startsWith("_"))
                truFolder = folder.substr(1);

            loopCount++;
            key += truFolder + (loopCount == pathArray.length ? "" : "/");
        }

        if(library != null)
            library = (library.startsWith("_") ? library.split("_")[1] : library);
        #end

        if(library == null)
            return 'assets/$key';
        else
            return 'assets/$library/$key';
    }
    
    public static function exists(filePath:String, ?library:String):Bool
        #if desktop
        return sys.FileSystem.exists(getPath(filePath, library));
        #else
        return openfl.Assets.exists(getPath(filePath, library));
        #end
    
    public static function getSound(key:String, ?library:String):Sound
    {
        if(!renderedSounds.exists(key))
        {
            if(!exists('$key.ogg', library)) {
                trace('$key.ogg doesnt exist!', "ERROR");
                return null;
            }
            //Logs.print('created new sound $key');
            renderedSounds.set(key,
                #if desktop
                Sound.fromFile(getPath('$key.ogg', library))
                #else
                openfl.Assets.getSound(getPath('$key.ogg', library), false)
                #end
            );
        }
        return renderedSounds.get(key);
    }

    public static function getGraphic(key:String, from:String = 'images', ?library:String):FlxGraphic
    {
        if(key.endsWith('.png'))
            key = key.substring(0, key.lastIndexOf('.png'));
        var path = getPath('$from/$key.png', library);
        if(exists('$from/$key.png', library))
        {
            if(!renderedGraphics.exists(key))
            {
                #if desktop
                var bitmap = BitmapData.fromFile(path);
                #else
                var bitmap = openfl.Assets.getBitmapData(path, false);
                #end
                
                var newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
                //Logs.print('created new image $key');
                
                renderedGraphics.set(key, newGraphic);
            }
            
            return renderedGraphics.get(key);
        }
        trace('$key does not exist!', "ERROR");
        return null;
    }
    
    /*  add .png at the end for images
    *   add .ogg at the end for sounds
    */
    public static var dumpExclusions:Array<String> = [
        "menus/alphabet.png"
    ];
    public static function clearMemory()
    {   
        // sprite caching
        var clearCount:Array<String> = [];
        for(key => graphic in renderedGraphics)
        {
            if(dumpExclusions.contains(key + '.png')) continue;

            clearCount.push(key);
            
            renderedGraphics.remove(key);
            if(openfl.Assets.cache.hasBitmapData(key))
                openfl.Assets.cache.removeBitmapData(key);
            
            FlxG.bitmap.remove(graphic);
            #if (flixel < "6.0.0")
            graphic.dump();
            #end
            graphic.destroy();
        }

        trace('cleared $clearCount', "DEBUG");
        trace('cleared ${clearCount.length} assets', "DEBUG");

        // uhhhh
        @:privateAccess
        for(key in FlxG.bitmap._cache.keys())
        {
            var obj = FlxG.bitmap._cache.get(key);
            if(obj != null && !renderedGraphics.exists(key))
            {
                openfl.Assets.cache.removeBitmapData(key);
                FlxG.bitmap._cache.remove(key);
                #if (flixel < "6.0.0")
                obj.dump();
                #end
                obj.destroy();
            }
        }
        
        // sound clearing
        for (key => sound in renderedSounds)
        {
            if(dumpExclusions.contains(key + '.ogg')) continue;
            
            Assets.cache.clear(key);
            renderedSounds.remove(key);
        }
    }
    
    public static function sound(key:String, from:String = 'music', ?library:String):Sound
        return getSound('$from/$key', library);
    
    public static function image(key:String, from:String = 'images', ?library:String):FlxGraphic
        return getGraphic(key, from, library);
    
    public static function font(key:String, ?library:String):String
        return getPath('fonts/$key', library);

    public static function text(key:String, ?library:String):String
        return Assets.getText(getPath('$key.txt', library)).trim();

    public static function getFileContent(filePath:String, ?library:String):String
        #if desktop
        return sys.io.File.getContent(getPath(filePath, library));
        #else
        return openfl.Assets.getText(getPath(filePath, library));
        #end

    public static function JSON(key:String, ?library:String):Dynamic
        return haxe.Json.parse(getFileContent('$key.json', library).trim());

    public static function video(key:String, ?library:String):String
        return getPath('videos/$key.mp4', library);
    
    // sparrow (.xml) sheets
    public static function getSparrowAtlas(key:String, from:String = 'images', ?library:String)
        return FlxAtlasFrames.fromSparrow(getGraphic(key, from, library), getPath('$from/$key.xml', library));
    
    // packer (.txt) sheets
    public static function getPackerAtlas(key:String, from:String = 'images', ?library:String)
        return FlxAtlasFrames.fromSpriteSheetPacker(getGraphic(key, from, library), getPath('$from/$key.txt', library));

    // aseprite (.json) sheets
    public static function getAsepriteAtlas(key:String, from:String = 'images', ?library:String)
        return FlxAtlasFrames.fromAseprite(getGraphic(key, from, library), getPath('$from/$key.json', library));

    // sparrow (.xml) sheets but split into multiple graphics
    public static function getMultiSparrowAtlas(baseSheet:String, from:String = 'images', otherSheets:Array<String>, ?library:String) {
        var frames:FlxFramesCollection = getSparrowAtlas(baseSheet, from);

        if(otherSheets.length > 0) {
            for(i in 0...otherSheets.length) {
                var newFrames:FlxFramesCollection = getSparrowAtlas(otherSheets[i], from);
                for(frame in newFrames.frames) {
                    frames.pushFrame(frame);
                }
            }
        }

        return frames;
    }

    // get single frame (for now sparrow only)
    public static function getFrame(key:String, from:String = 'images', frame:String, ?library:String):FlxGraphic
        return FlxGraphic.fromFrame(getSparrowAtlas(key, from).getByName(frame));
        
    public static function readDir(dir:String, ?typeArr:Array<String>, ?removeType:Bool = true, ?library:String):Array<String>
    {
        var swagList:Array<String> = [];
        
        try {
            #if desktop
            var rawList = sys.FileSystem.readDirectory(getPath(dir, library));
            for(i in 0...rawList.length)
            {
                if(typeArr?.length > 0)
                {
                    for(type in typeArr) {
                        if(rawList[i].endsWith(type)) {
                            // cleans it
                            if(removeType)
                                rawList[i] = rawList[i].replace(type, "");
                            swagList.push(rawList[i]);
                        }
                    }
                }
                else
                    swagList.push(rawList[i]);
            }
            #end
        } catch(e) {}
        
        trace('read dir ${(swagList.length > 0) ? '$swagList' : 'EMPTY'} at ${getPath(dir, library)}', "DEBUG");
        return swagList;
    }

    public static function preloadGraphic(key:String, from:String = 'images', ?library:String)
    {
        // no point in preloading something already loaded duh
        if(renderedGraphics.exists(key)) return;

        var what = new FlxSprite().loadGraphic(image(key, from, library));
        FlxG.state.add(what);
        FlxG.state.remove(what);
    }
    public static function preloadSound(key:String, from:String = 'music', ?library:String)
    {
        if(renderedSounds.exists(key)) return;

        var what = new FlxSound().loadEmbedded(getSound('$from/$key', library), false, false);
        what.play();
        what.stop();
    }

    public inline static function playSFX(key:String)
        return FlxG.sound.play(sound('$key', 'sounds'), MoonSettings.callSetting('SFX Volume') / 100);

    public static inline function spaceToDash(string:String):String
        return string.replace(" ", "-");

    public static inline function dashToSpace(string:String):String
        return string.replace("-", " ");

    public static inline function swapSpaceDash(string:String):String
        return string.contains('-') ? dashToSpace(string) : spaceToDash(string);
}

/**
 * An typedef for animation data, useful for spritesheets with jsons.
 */
typedef AnimationData = {
    var name:String;
    var prefix:String;
    var ?indices:Array<Int>;
    var ?x:Float;
    var ?y:Float;
    var ?fps:Int;
    var ?looped:Bool;
}