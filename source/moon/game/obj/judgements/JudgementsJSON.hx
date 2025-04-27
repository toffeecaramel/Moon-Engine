package moon.game.obj.judgements;

/**
 * A typedef for the game's judgements and combo data.
 */
typedef JudgementsJSON = {
    /**
     * The size of the judgements (not in width/height, but in scale.x & y instead)
     */
    var judgementScale:Float;

    /**
     * The size of the combo numbers (not in width/height, but in scale.x & y instead)
     */
    var numberScale:Float;

    /**
     * The spacing between each number for the combos.
     * Remind that: it already accounts width.
     */
    var numberSpacing:Float;

    /**
     * The offsets for the roll animation. Not necessary if it doesn't exist.
     */
    var ?rollOffsets:Array<Float>;

    /**
     * Whether the combos and judgements should have antialiasing or not.
     */
    var antialiasing:Bool;
}