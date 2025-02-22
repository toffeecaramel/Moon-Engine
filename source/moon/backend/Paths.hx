package moon.backend;

import haxe.Json;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.system.System;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display3D.textures.RectangleTexture;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
using StringTools;

typedef AnimationData = {
    var name:String;
    var prefix:String;
    var x:Float;
    var y:Float;
    var fps:Int;
    var looped:Bool;
}

class Paths
{
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedTextures:Map<String, Texture> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];
    public static var localTrackedAssets:Array<String> = [];

    
    static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true) 
    {
        if(bitmap == null) {
            if (OpenFlAssets.exists(file, IMAGE))
                bitmap = OpenFlAssets.getBitmapData(file);

            if(bitmap == null) return null;
        }

        localTrackedAssets.push(file);
        if (allowGPU)
        {
            var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
            texture.uploadFromBitmapData(bitmap);
            bitmap.image.data = null;
            bitmap.dispose();
            bitmap.disposeImage();
            bitmap = BitmapData.fromTexture(texture);
        }

        var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;
        newGraphic.destroyOnNoUse = false;
        currentTrackedAssets.set(file, newGraphic);

        return newGraphic;
    }

    public static function returnGraphic(key:String, ?from:String = 'images', ?library:String, ?textureCompression:Bool = false)
    {
        var path = getPath('$from/$key.png', IMAGE, library);

        if (#if sys FileSystem.exists(path) #else OpenFlAssets.exists(path) #end)
        {
            if (!currentTrackedAssets.exists(key))
            {
                var bitmap = BitmapData.fromFile(path);
                var newGraphic:FlxGraphic;
                if (textureCompression)
                {
                    var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
                    texture.uploadFromBitmapData(bitmap);
                    currentTrackedTextures.set(key, texture);
                    bitmap.dispose();
                    bitmap.disposeImage();
                    bitmap = null;
                    newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
                }
                else
                    newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);

                currentTrackedAssets.set(key, newGraphic);
            }
            localTrackedAssets.push(key);
            return currentTrackedAssets.get(key);
        }
        trace('$key didn\'t load. Did you type the path correctly?', "ERROR");
        return null;
    }
    
    
    inline static function getLibraryPathForce(file:String, library:String)
        return '$library/$file';

    
    // - Other utilities. - //

    public static inline function spaceToDash(string:String):String
        return string.replace(" ", "-");

    public static inline function dashToSpace(string:String):String
        return string.replace("-", " ");

    public static inline function swapSpaceDash(string:String):String
        return string.contains('-') ? dashToSpace(string) : spaceToDash(string);

    /**
     * Clears any asset that got loaded up but went unused.
     * @param dumpExclusions 
     */
    public static function clearUnusedMemory(?dumpExclusions:Array<String> = null)
    {
        if (dumpExclusions == null)
            dumpExclusions = [];
    
        var counter:Int = 0;
    
        for (key in currentTrackedAssets.keys())
        {
            // - Check if the asset is not locally tracked and is not excluded
            if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
            {
                var obj = currentTrackedAssets.get(key);
                if (obj != null)
                {
                    obj.persist = false;
                    obj.destroyOnNoUse = true;
    
                    // - Check if the asset has a texture and dispose of it
                    if (currentTrackedTextures.exists(key))
                    {
                        var texture = currentTrackedTextures.get(key);
                        texture.dispose();
                        currentTrackedTextures.remove(key);
                    }
    
                    // - Remove cached bitmap data if present
                    @:privateAccess
                    if (openfl.Assets.cache.hasBitmapData(key))
                    {
                        openfl.Assets.cache.removeBitmapData(key);
                        FlxG.bitmap._cache.remove(key);
                    }
    
                    // - Destroy the graphic and remove from tracked assets
                    obj.destroy();
                    currentTrackedAssets.remove(key);
                    counter++;
                }
            }
        }
    
        System.gc();
        trace('$counter unused assets have been cleared.');
    }
    
    /**
     * Clears every asset in the game's memory.
     * @param cleanUnused 
     * @param dumpExclusions 
     */
    public static function clearStoredMemory(?cleanUnused:Bool = false, ?dumpExclusions:Array<String> = null)
    {
        var counter = 0;

        if (dumpExclusions == null)
            dumpExclusions = [];
    
        // - Clear all cached bitmap data not in the tracked list
        @:privateAccess
        for (key in FlxG.bitmap._cache.keys())
        {
            final obj = FlxG.bitmap._cache.get(key);

            if (obj != null && (!currentTrackedAssets.exists(key) || !cleanUnused))
            {
                openfl.Assets.cache.removeBitmapData(key);
                FlxG.bitmap._cache.remove(key);
                obj.destroy();
                counter++;
            }
        }
    
        // - Clear all cached sounds
        for (key in currentTrackedSounds.keys())
        {
            if ((!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) || !cleanUnused)
            {
                if (currentTrackedSounds.exists(key))
                {
                    var sound = currentTrackedSounds.get(key);
                    if (sound != null)
                        sound.close();

                    counter++;
                    currentTrackedSounds.remove(key);
                }
            }
        }
    
        // - Clear all cached textures
        for (key in currentTrackedTextures.keys())
        {
            if ((!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) || !cleanUnused)
            {
                if (currentTrackedTextures.exists(key))
                {
                    var texture = currentTrackedTextures.get(key);
                    if (texture != null)
                        texture.dispose();

                    counter++;
                    currentTrackedTextures.remove(key);
                }
            }
        }
    
        // - Clear all tracked assets if not flagged as unused
        if (!cleanUnused)
        {
            localTrackedAssets = [];
            currentTrackedAssets.clear();
        }
    
        // - Force garbage collection
        System.gc();
        trace('$counter assets have been cleared.');
    } 
    
    // - Path-related utilities. - //
    
    static public function getLibraryPath(file:String, library = "preload")
        return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);

    inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
        return getPath(file, type, library);
    
    /**
     * Returns a music file from the music path.
     * @param file 
     * @param from (can be either images, data, etc.)
     * @return return 'assets/music/$file.ogg'
     */
    inline static public function audio(file:String, ?from:String = 'music')
        return 'assets/$from/$file.ogg';

    /**
     * Returns a font file from the fonts path. (MUST INCLUDE FILE FORMAT!)
     * @param file 
     * @return return 'assets/fonts/$file'
     */
    inline static public function font(file:String)
        return 'assets/fonts/$file';

    /**
     * Returns a file from the data path. (MUST INCLUDE FILE FORMAT!)
     * @param file 
     * @return return 'assets/data/$file'
     */
    inline static public function data(file:String)
        return 'assets/data/$file';

    /**
     * Returns a shader (frag) file from the shaders path.
     * @param file 
     * @return return 'assets/shaders/$file.frag'
     */
    inline static public function frag(file:String)
        return 'assets/shaders/$file.frag';

    /**
     * Returns a entire parsed JSON content from a path.
     * @param file 
     * @param from (can be either images, data, etc.)
     * @return return (json content)
     */
    inline static public function JSON(file:String, ?from:String = 'images')
        return Json.parse(#if sys File.getContent('assets/$from/$file.json') #else OpenFlAssets.getText('assets/$from/$file.json') #end);

    /**
     * Returns a image graphic from a specified file path.
     * @param key (path)
     * @param from (can be either images, data, etc.)
     * @param library 
     * @param allowGPU if the graphic will be gpu-loaded
     * @return FlxGraphic
     */
    static public function image(key:String, ?from:String = 'images', ?library:String = null, ?allowGPU:Bool = true):FlxGraphic 
    {
        var file:String = getPath('$from/$key.png', IMAGE, library);

        if (currentTrackedAssets.exists(file))
        {
            localTrackedAssets.push(file);
            return currentTrackedAssets.get(file);
        }

        var bitmap:BitmapData = OpenFlAssets.exists(file, IMAGE) ? OpenFlAssets.getBitmapData(file) : null;

        if (bitmap != null) {
            var retVal = cacheBitmap(file, bitmap, allowGPU);
            if(retVal != null) return retVal;
        }

        trace('$file is returning null.', "ERROR");
        return null;
    }

    /**
     * Returns a animated Sparrow Atlas from a specified path.
     * @param key (path)
     * @param from (can be either from images, data, etc.)
     * @param library 
     * @param textureCompression whether or not should the texture be compressed.
     */
    inline static public function getSparrowAtlas(key:String, ?from:String = 'images', ?library:String, ?textureCompression:Bool = false)
    {
        var graphic:FlxGraphic = returnGraphic(key, from, library, textureCompression);
        return (FlxAtlasFrames.fromSparrow(graphic, #if sys File.getContent(file('$from/$key.xml', library)) #else OpenFlAssets.getText(file('$from/$key.xml', library))#end));
    }
    
    inline public static function getPath(file:String, type:AssetType, ?library:Null<String>)
    {
        if (library != null)
            return getLibraryPath(file, library);

        var levelPath = getLibraryPathForce(file, "mods");
        if (OpenFlAssets.exists(levelPath, type))
            return levelPath;

        return getPreloadPath(file);
    }

    inline static function getPreloadPath(file:String)
    {
        var returnPath:String = 'assets/$file';
        if (#if sys !FileSystem.exists(returnPath) #else !OpenFlAssets.exists(returnPath) #end)
            returnPath = swapSpaceDash(returnPath);
        return returnPath;
    }
}