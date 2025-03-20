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
    var ?indices:Array<Int>;
    var x:Float;
    var y:Float;
    var fps:Int;
    var looped:Bool;
}

class Paths
{
    /**
     * An map containing all the currently tracked assets.
     */
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

    /**
     * An map containing all the currently tracked textures.
     */
    public static var currentTrackedTextures:Map<String, Texture> = [];

    /**
     * An map containing all the currently tracked sounds.
     */
    public static var currentTrackedSounds:Map<String, Sound> = [];

    /**
     * An array containing all the locally tracked assets.
     */
    public static var localTrackedAssets:Array<String> = [];

    /**
     * On upon calling, this function will cache a bitmap in memory.
     * @param file file path
     * @param bitmap bitmap data
     * @param allowGPU whether or not to load on GPU.
     */
    static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true)
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

        if (fileExists(path, IMAGE))
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

    // - Cleanup utilities. - //

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
        trace('$counter unused assets have been cleared.', "DEBUG");
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

        System.gc();
        trace('$counter assets have been cleared.', "DEBUG");
    }

    // - Path-related utilities. - //

    /**
     * Helper function to check if a file exists, handling sys/non-sys differences.
     * @param path The path to the file.
     * @param type The AssetType (can be null if only checking for existence, but useful for consistency)
     */
     public inline static function fileExists(path:String, ?type:AssetType):Bool
        return #if sys FileSystem.exists(path); #else return OpenFlAssets.exists(path, type); #end

    /**
     * Helper function to get file content as text, handling sys/non-sys differences.
     * @param path The path to the file.
     * @param type The AssetType (TEXT in most cases)
     * @return The file content.
     */
    public inline static function getFileContent(path:String):String
        return #if sys File.getContent(path); #else OpenFlAssets.getText(path); #end

    public inline static function saveFileContent(path:String, content:Dynamic)
        return #if sys File.saveContent(path, content); #else throw 'File Saving is only available on Desktop.'; #end

    static public function getLibraryPath(file:String, library = "preload")
        return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);

    inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
        return getPath(file, type, library);

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
    inline static public function JSON(file:String, ?from:String = 'images'):Dynamic
    {
        var path = 'assets/$from/$file.json';
        if (fileExists(path, TEXT))
            return Json.parse(getFileContent(path));

        return Json.parse(getFileContent(path));
    }

        /**
     * Loads a sound from the file system dynamically.
     * @param key The name of the sound file (without extension).
     * @param from The subdirectory within 'assets' (e.g., 'music', 'sounds').
     * @param library Optional library.
     * @return The loaded Sound object, or null if loading fails.
     */
    public static function sound(key:String, ?from:String = 'music', ?library:String):Null<Sound>
    {
        var path = getPath('$from/$key.ogg', SOUND, library);

        if (currentTrackedSounds.exists(key))
        {
            localTrackedAssets.push(key);
            return currentTrackedSounds.get(key);
        }

        if (fileExists(path, SOUND))
        {
            var newSound = Sound.fromFile(path);
            currentTrackedSounds.set(key, newSound);
            localTrackedAssets.push(key);
            return newSound;
        }

        trace('Sound $key not found. Did you place the file correctly?', "ERROR");
        return null;
    }

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
     * Returns a animated Sparrow Atlas from a specified path.
     * @param key (path)
     * @param from (can be either from images, data, etc.)
     * @param library
     * @param textureCompression whether or not should the texture be compressed.
     */
    inline static public function getSparrowAtlas(key:String, ?from:String = 'images', ?library:String, ?textureCompression:Bool = false)
    {
        var graphic:FlxGraphic = returnGraphic(key, from, library, textureCompression);
        var xmlPath = file('$from/$key.xml', TEXT, library);
        var xmlContent = "";
        if (fileExists(xmlPath, TEXT))
            xmlContent = getFileContent(xmlPath);
        else if (OpenFlAssets.exists(xmlPath, TEXT))
            xmlContent = OpenFlAssets.getText(xmlPath);

        return (FlxAtlasFrames.fromSparrow(graphic, xmlContent));
    }

    inline public static function getPath(file:String, type:AssetType, ?library:Null<String>)
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