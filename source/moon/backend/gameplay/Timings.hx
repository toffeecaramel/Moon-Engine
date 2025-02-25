// in Timings.hx
package moon.backend.gameplay;

import flixel.util.FlxColor;

class Timings
{
    public static var judgementsMap:Map<String, Array<Dynamic>> = [
        /**
            ID (0) - Unused so far
            max milliseconds (1)
            score from it (2)
            health gain (3)
            judgement color (4)
        **/
        'sick' => [0,   45,      350,   4,     0xFF2883ff],
        'good' => [1,   90,      150,   2,     0xFF44cd4d],
        'bad'  => [2,   135,     0,     0,     0xFFa8738a],
        'shit' => [3,   157.5,  -50,   -2,     0xFF59443f],
        'miss' => [4,   180,    -600,  -4.5,  0xFF894331]
    ];

    public static var judgementsCounter:Map<String, Int> =
    [
        'sick' => 0,
        'good' => 0,
        'bad' => 0,
        'shit' => 0,
        'miss' => 0
    ];

    public static var values(get, default):Array<String>;

    public static function getParameters(jt:String):Array<Dynamic>
        return judgementsMap.get(jt);

    @:noCompletion
    public static function get_values():Array<String>
    {
        values = ['sick', 'good', 'bad', 'shit', 'miss'];
        return values;
    }
}