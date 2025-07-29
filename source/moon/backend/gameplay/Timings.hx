package moon.backend.gameplay;

import flixel.util.FlxColor;

@:publicFields
class Timings
{
    static var judgementsMap:Map<String, Array<Dynamic>> = [
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

    static var values(get, default):Array<String>;

    /**
     * Get a rank based on accuracy.
     * @param accuracy The accuracy value.
     * @param short Whether or not should the rank be short.
     */  
    static function getRank(accuracy:Float, ?short:Bool = false):String
    {
        final thresholds:Array<{limit:Float, rank:String, short:String}> = [
            {limit: 60, rank: 'LOSS', short: 'L'},
            {limit: 80, rank: 'GOOD', short: 'G'},
            {limit: 90, rank: 'GREAT', short: 'G'},
            {limit: 98, rank: 'EXCELLENT', short: 'E'},
            {limit: 100, rank: 'PERFECT', short: 'P'}
        ];

        for (t in thresholds)
            if (accuracy < t.limit)
                if(short)
                {
                    return t.short;
                }
                else
                {
                    return t.rank;
                }

        if(!short)
            return 'PERFECT-GOLD';
        else
            return 'P';
    }

    static function getRankColor(rank:String):FlxColor
    {
        switch (rank)
        {
            case 'LOSS': return 0xFF6044FF;
            case 'GOOD': return 0xFFEF8764;
            case 'GREAT' :return 0xFFEAF6FF;
            case 'EXCELLENT': return 0xFFFDCB42;
            case 'PERFECT': return 0xFFFF58B4;
            case 'PERFECT-GOLD': return 0xFFFFB619;
            default: return FlxColor.WHITE;
        }
    }

    /**
     * Get a parameter data from a judgement.
     * @param jt The judgement that will iterate data from.
     */
    static function getParameters(jt:String):Array<Dynamic>
        return judgementsMap.get(jt);

    @:noCompletion
    static function get_values():Array<String>
    {
        values = ['sick', 'good', 'bad', 'shit', 'miss'];
        return values;
    }
}