package moon.backend.gameplay;

@:publicFields
class PlayerStats
{
    /**
     * Used for storing total notes that got hit or missed by the player.
     */
    var totalNotes(default, set):Int = 0;

    /**
     * Used for checking a total accuracy you got on said judgement.
     */
    var accuracyCount(default, set):Float = 0;

    /**
     * Total accuracy by said player.
     */
    var accuracy:Float = 0;

    /**
     * Total misses by said player, either by ghost tapping or missing notes.
     */
    var misses(default, set):Int = 0;

    /**
     * Total score by said player, gained by each note hit, depending on the Timing it got.
     */
    var score:Int = 0;

    /**
     * The combo of notes hit in a row without missing.
     */
    var combo(default, set):Int = 0;

    /**
     * The combo of notes hit in a row without missing, except it doesn't take sustain notes in account.
     */
    var noSustainCombo(default, set):Int = 0;

    /**
     * The highest combo the player got.
     */
    var highestCombo:Int = 0;

    /**
     * The highest combo the player got, ignoring the sustains.
     */
    var noSustainHighestCombo:Int = 0;

    /**
     * The total health by said player.
     */
    var health:Float = 50;

    /**
     * The ID of this player.
     */
    var playerID:String = 'p1';

    /**
     * A map containing all the notes hit on said judgement.
     */
    public var judgementsCounter:Map<String, Int> =
    [
        'sick' => 0,
        'good' => 0,
        'bad' => 0,
        'shit' => 0,
        'miss' => 0
    ];

    /**
     * Creates states for a specific player
     * @param playerID The player ID that'll be used. (e.g. `p1, opponent[...]`)
     */
    public function new(playerID:String = 'p1')
    {
        this.playerID = playerID;
        reset();
    }

    /**
     * Function called for updating the accuracy based on everything.
     */
    function updtAccuracy()
        accuracy = Math.round((accuracyCount / totalNotes) * 10000) / 100;

    /**
     * Returns how much percentage of totalNotes was reached with noSustainCombo.
     * The result goes from 0 to 100. (TODO)
     */
    public function calcClear():Float
        return 0;

    /**
     * Resets all stats on upon calling.
     */
    function reset()
    {
        accuracyCount = totalNotes = 0;
        accuracy = misses = score = combo = 0;
        health = 50;
    }

    @:noCompletion function set_accuracyCount(value:Float):Float
    {
        accuracyCount = value;
        updtAccuracy();
        return value;
    }

    @:noCompletion function set_totalNotes(value:Int):Int
    {
        totalNotes = value;
        updtAccuracy();
        return value;
    }

    @:noCompletion function set_misses(misses:Int):Int
    {
        this.misses = misses;

        judgementsCounter.set('miss', judgementsCounter.get('miss') + 1);

        return this.misses;
    }

    @:noCompletion function set_combo(combo:Int):Int
    {
        this.combo = combo;

        if (combo > highestCombo)
            highestCombo = combo;

        return this.combo;
    }

    @:noCompletion function set_noSustainCombo(noSustainCombo:Int):Int
    {
        this.noSustainCombo = noSustainCombo;

        if (noSustainCombo > noSustainHighestCombo)
            noSustainHighestCombo = noSustainCombo;

        return this.noSustainCombo;
    }
}