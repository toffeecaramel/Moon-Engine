package moon;

@:publicFields

/**
 * This class has global variables (which can't go into Constants since they can be changed).
 */
class Global
{
    /**
     * Whether or not to allow inputs on the game (Only applied when MoonInput is used).
     */
    static var allowInputs:Bool = true;
}