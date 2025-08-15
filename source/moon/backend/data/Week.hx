package moon.backend.data;

typedef WeekFile = {
    var displayName:String;
    var description:String;
    
    var diffRating:Int;
    var tracks:Array<String>;
    
    var colors:Array<Int>;
    var weekImage:String;
    var bgImage:String;
}

@:publicFields
@:forward
abstract Week(WeekFile) from WeekFile to WeekFile
{
    static function getWeek(week:String):Week
    {
        if(Paths.exists('data/weeks/$week'))
            return Paths.JSON('data/weeks/$week/$week');
        else
            trace('$week was not found within the week directory.', "ERROR");

        return null;
    }
}