package moon.toolkit.ui;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import moon.other.*;

class Tabs extends FlxGroup
{
    private var tabs:Array<{name:String, tag:String}>;
    private var tabGroups:Map<String, FlxGroup>;
    private var activeTab:String;
    private var labels:Array<ToggleButton>;
    private var tabTitle:FlxText;
    private var xPos:Float;
    private var yPos:Float;

    /**
     * Creates a pop-up with tabs.
     * @param x     The X position of the entire object.
     * @param y     The Y position of the entire object.
     * @param tabs  The tabs. Usage example: `[{name: "My Tab Title", tag: "mytabtag"}, {name: "My Tab 2", tag: "tag2"}]`
     */
    public function new(x:Float, y:Float, tabs:Array<{name:String, tag:String}>)
    {
        super();
        this.tabs = tabs;
        this.tabGroups = new Map<String, FlxGroup>();
        this.labels = [];
        this.xPos = x;
        this.yPos = y;
        
        initializeTabs();
    }

    private function initializeTabs():Void
    {
        var yOffset:Float = 0;
        var bg = new MoonSprite(xPos + 64, yPos).makeGraphic(442, 360, 0xFF000000);
        add(bg);

        var separator = new MoonSprite(bg.x, yPos + 64).makeGraphic(Std.int(bg.width), 2, 0xFF434753);
        add(separator);

        for (tab in tabs)
        {
            var labelButton = createTabLabel(tab, xPos, yPos + yOffset);
            labels.push(labelButton);
            add(labelButton);
            add(labelButton.icon);
            yOffset += labelButton.height;
            
            var tabGroup = new FlxGroup();
            tabGroup.visible = false;
            tabGroups.set(tab.tag, tabGroup);
            add(tabGroup);
        }

        final fontSize:Int = 24;
        tabTitle = new FlxText(xPos + 64 + fontSize, yPos + (fontSize));
        tabTitle.setFormat(Paths.font('vcr.ttf'), fontSize, LEFT);
        add(tabTitle);
        
        if (tabs.length > 0)
            activateTab(tabs[0].tag);
    }

    private function createTabLabel(tab:{name:String, tag:String}, x:Float, y:Float):ToggleButton
    {
        var labelButton = new ToggleButton(x, y, 64, 64, flixel.util.FlxColor.BLACK, Paths.image('toolkit/level-editor/icons/tabs/${tab.tag}'), () -> activateTab(tab.tag));
        labelButton.strID = tab.tag;
        return labelButton;
    }

    private function activateTab(tag:String):Void
    {
        // - Hide all tab groups
        for (tabGroup in tabGroups)
            tabGroup.visible = false;

        activeTab = tag;
        tabGroups.get(tag).visible = true;
        
        for (label in labels)
            label.selected = (label.strID == activeTab);

        tabTitle.text = getTabName(tag);
    }

    private function getTabName(tag:String):String {
        for (tab in tabs)
            if (tab.tag == tag)
                return tab.name;
        return "Unknown";
    }

    /**
     * Adds an object to a specific tab by tag.
     * @param tag The tag of the tab to add to.
     * @param obj The FlxObject to add to the tab.
     */
    public function addTo(tag:String, obj:Dynamic):Void
        (tabGroups.exists(tag)) ? tabGroups.get(tag).add(obj) : trace('Tab with tag \'$tag\' does not exist. Please specify a valid one!', "ERROR");
}
