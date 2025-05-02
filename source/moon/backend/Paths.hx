package moon.backend;

import haxe.Json;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
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

@:publicFields

/**
 * A class containing mostly utilities for saving/loading files from specific types.
 */
class Paths
{
    /**
     * Map for cached graphics
     */
    static var currentTrackedAssets:Map<String, FlxGraphic> = [];

    /**
     * Map for cached GPU textures
     */
    static var currentTrackedTextures:Map<String, Texture> = [];

    /**
     * Map for cached sounds
     */
    static var currentTrackedSounds:Map<String, Sound> = [];

    /**
     * List of asset keys currently in use
     */
    static var localTrackedAssets:Array<String> = [];

    /**
     * Reference counts for the assets.
     */
    static var assetRefCounts:Map<String, Int> = [];

    // ----------------------------
    // Caching & Reference Counting
    // ----------------------------

    /**
     * Increases the reference count for an asset.
     * @param key The asset key.
     */
    static function addAssetRef(key:String):Void
    {
        if (assetRefCounts.exists(key))
            assetRefCounts.set(key, assetRefCounts.get(key) + 1);
        else
            assetRefCounts.set(key, 1);
    }

    /**
     * Decreases the reference count for an asset.
     * @param key The asset key.
     */
    static function removeAssetRef(key:String):Void
    {
        if (assetRefCounts.exists(key))
        {
            var count = assetRefCounts.get(key) - 1;
            (count <= 0) ? assetRefCounts.remove(key) : assetRefCounts.set(key, count);
        }
    }

    /**
     * Cache a bitmap to a FlxGraphic with optional texture compression.
     */
    static function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true)
    {
        if (bitmap == null)
        {
            if (fileExists(file, IMAGE))
            {
                #if sys
                bitmap = BitmapData.fromFile(file);
                #else
                bitmap = OpenFlAssets.getBitmapData(file);
                #end
            }
            if(bitmap == null) return null;
        }

        // Mark asset usage and increase reference count
        localTrackedAssets.push(file);
        addAssetRef(file);

        if (allowGPU)
        {
            // Create a compressed texture on 'gpu'
            final texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
            texture.uploadFromBitmapData(bitmap);
            bitmap.image.data = null;
            bitmap.dispose();
            bitmap.disposeImage();
            // Recreate the bitmap from the texture to use as a graphic source
            bitmap = BitmapData.fromTexture(texture);
        }

        final newGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;
        newGraphic.destroyOnNoUse = false;
        currentTrackedAssets.set(file, newGraphic);
        return newGraphic;
    }

    /**
     * Returns a FlxGraphic by key.
     * If not already loaded, loads it (with optional texture compression).
     */
    static function returnGraphic(key:String, ?from:String = 'images', ?library:String, ?textureCompression:Bool = false)
    {
        var path = getPath('$from/$key.png', IMAGE, library);
        if (fileExists(path, IMAGE))
        {
            // Increase reference count on usage.
            addAssetRef(key);

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
                    bitmap = BitmapData.fromTexture(texture);
                    newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
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

    // ----------------------------
    // Other Utility Methods
    // ----------------------------

    static inline function spaceToDash(string:String):String
        return string.replace(" ", "-");

    static inline function dashToSpace(string:String):String
        return string.replace("-", " ");

    static inline function swapSpaceDash(string:String):String
        return string.contains('-') ? dashToSpace(string) : spaceToDash(string);

    // ----------------------------
    // Cleanup Utilities
    // ----------------------------

    /**
     * Clears any asset that got loaded up but went unused.
     * dumpExclusions: keys to ignore.
     */
    static function clearUnusedMemory(?dumpExclusions:Array<String> = null)
    {
        if (dumpExclusions == null)
            dumpExclusions = [];
        var counter:Int = 0;
        for (key in currentTrackedAssets.keys())
        {
            // Check if the asset is not locally tracked, not excluded, or has a low reference count.
            if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
            {
                // Optionally, you can check the assetRefCounts here:
                if (assetRefCounts.exists(key) && assetRefCounts.get(key) > 0)
                    continue;

                var obj = currentTrackedAssets.get(key);
                if (obj != null)
                {
                    obj.persist = false;
                    obj.destroyOnNoUse = true;
                    // Dispose texture if present.
                    if (currentTrackedTextures.exists(key))
                    {
                        var texture = currentTrackedTextures.get(key);
                        texture.dispose();
                        currentTrackedTextures.remove(key);
                    }
                    // Remove from the OpenFL cache.
                    @:privateAccess
                    if (openfl.Assets.cache.hasBitmapData(key))
                    {
                        openfl.Assets.cache.removeBitmapData(key);
                        FlxG.bitmap._cache.remove(key);
                    }
                    obj.destroy();
                    currentTrackedAssets.remove(key);
                    counter++;
                }
            }
        }
        System.gc();
        trace('$counter unused assets have been cleared.', "DEBUG");
    }

    /**
     * Clears every asset in the game's memory.
     * @param cleanUnused flag for aggressive cleanup.
     * @param dumpExclusions keys to ignore.
     */
    static function clearStoredMemory(?cleanUnused:Bool = false, ?dumpExclusions:Array<String> = null)
    {
        var counter = 0;
        if (dumpExclusions == null)
            dumpExclusions = [];

        // Clear cached bitmap data not tracked.
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

        // Clear cached sounds.
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

        // Clear cached textures.
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

        if (!cleanUnused)
        {
            localTrackedAssets = [];
            currentTrackedAssets.clear();
        }

        System.gc();
        trace('$counter assets have been cleared.', "DEBUG");
    }

    // ----------------------------
    // Path & File Utilities
    // ----------------------------

    /**
     * Helper function to check if a file exists.
     */
    inline static function fileExists(path:String, ?type:AssetType):Bool
        return #if sys FileSystem.exists(path); #else return OpenFlAssets.exists(path, type); #end

    /**
     * Gets file content as text.
     */
    inline static function getFileContent(path:String):String
        return #if sys File.getContent(path); #else OpenFlAssets.getText(path); #end

    /**
     * Saves file content on specified path.
     */
    inline static function saveFileContent(path:String, content:Dynamic)
        return #if sys File.saveContent(path, content); #else throw 'File Saving is only available on Desktop.'; #end

    static function getLibraryPath(file:String, library = "preload")
        return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);

    inline static function getLibraryPathForce(file:String, library:String)
        return '$library/$file';

    /**
     * Returns a font file from the fonts path.
     */
    inline static function font(file:String):String
        return getPath('fonts/$file', TEXT);

    /**
     * Returns a file from the data path.
     */
    inline static function data(file:String):String
        return getPath('data/$file', TEXT);

    /**
     * Returns a shader (frag) file from the shaders path.
     */
    inline static function frag(file:String)
        return getPath('shaders/$file.frag', TEXT);

    inline static function mp4(file:String)
        return getPath('videos/$file.mp4', null);

    /**
     * Returns parsed JSON content from a given path.
     */
    inline static function JSON(file:String, ?from:String = "images"):Dynamic
    {
        final path = getPath('$from/$file.json', TEXT);
        return Json.parse(getFileContent(path));
    }

    /**
     * Loads a sound from the file system.
     */
    static function sound(key:String, ?from:String = 'music', ?library:String):Null<Sound>
    {
        var path = getPath('$from/$key.ogg', SOUND, library);
        if (currentTrackedSounds.exists(key))
        {
            localTrackedAssets.push(key);
            addAssetRef(key);
            return currentTrackedSounds.get(key);
        }

        if (fileExists(path, SOUND))
        {
            var newSound = Sound.fromFile(path);
            currentTrackedSounds.set(key, newSound);
            localTrackedAssets.push(key);
            addAssetRef(key);
            return newSound;
        }

        trace('Sound $key not found. Did you place the file correctly?', "ERROR");
        return null;
    }

    /**
     * Returns a FlxGraphic image.
     */
    static function image(key:String, ?from:String = 'images', ?library:String = null, ?allowGPU:Bool = true):FlxGraphic
    {
        var file:String = getPath('$from/$key.png', IMAGE, library);

        if (currentTrackedAssets.exists(file))
        {
            localTrackedAssets.push(file);
            addAssetRef(file);
            return currentTrackedAssets.get(file);
        }

        var bitmap:BitmapData = null;
        if (fileExists(file, IMAGE))
            bitmap = BitmapData.fromFile(file);
        else if (OpenFlAssets.exists(file, IMAGE))
            bitmap = OpenFlAssets.getBitmapData(file);
        if (bitmap != null)
        {
            var retVal = cacheBitmap(file, bitmap, allowGPU);
            if (retVal != null) return retVal;
        }
        
        trace('$file is returning null.', "ERROR");
        return null;
    }

    /**
     * Returns a Sparrow Atlas for animations.
     */
    inline static function getSparrowAtlas(key:String, ?from:String = 'images', ?library:String, ?textureCompression:Bool = false)
    {
        var graphic:FlxGraphic = returnGraphic(key, from, library, textureCompression);
        final xmlPath = getPath('$from/$key.xml', TEXT, library);

        final xmlContent = (fileExists(xmlPath, TEXT)) ? getFileContent(xmlPath) : (OpenFlAssets.exists(xmlPath, TEXT)) ? OpenFlAssets.getText(xmlPath) : null;
        return (FlxAtlasFrames.fromSparrow(graphic, xmlContent));
    }

    // ----------------------------
    // Sound Playback Utilities
    // ----------------------------
    inline static function playSFX(path:String)
        return FlxG.sound.play(Paths.sound('$path', 'sounds'), MoonSettings.callSetting('SFX Volume') / 100);

    //TODO: Other sound playback utils
    // ----------------------------
    // Others
    // ----------------------------

    inline static function getPath(file:String, type:AssetType, ?library:Null<String>)
    {
        if (library != null)
            return getLibraryPath(file, library);

        var filePath = getPreloadPath(file);
        if (fileExists(filePath, type))
            return filePath;

        var levelPath = getLibraryPathForce(file, "mods");
        if (OpenFlAssets.exists(levelPath, type))
            return levelPath;
        return getPreloadPath(file);
    }

    inline static function getPreloadPath(file:String)
    {
        var returnPath:String = 'assets/$file';
        if (!fileExists(returnPath, TEXT))
            returnPath = swapSpaceDash(returnPath);
        return returnPath;
    }
}