package moon.backend.gameplay;

import flixel.util.FlxColor;

class Timings
{
    public static var judgementsMap:Map<String, Array<Dynamic>> = [
        /**
            Accuracy count (0)
            max milliseconds (1)
            score from it (2)
            health gain (3)
            judgement color (4)
        **/
        'sick' => [1.0,     45,      350,   2,     0xFF2883ff],
        'good' => [0.5,     90,      150,   1,     0xFF44cd4d],
        'bad'  => [-0.02,   135,     0,     0.5,   0xFFa8738a],
        'shit' => [-0.5,    157.5,  -50,   -1,     0xFF59443f],
        'miss' => [-1.0,    180,    -600,  -4.5,   0xFF894331]
    ];

    public static var values(get, default):Array<String>;

    /**
     * Get a parameter data from a judgement.
     * @param jt The judgement that will iterate data from.
     */
    public static function getParameters(jt:String):Array<Dynamic>
        return judgementsMap.get(jt);

    @:noCompletion
    public static function get_values():Array<String>
    {
        values = ['sick', 'good', 'bad', 'shit', 'miss'];
        return values;
    }
}