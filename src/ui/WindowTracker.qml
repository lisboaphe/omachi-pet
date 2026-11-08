import QtQuick
import Quickshell.Hyprland
import "../game/World.js" as World
QtObject {
    id: root
    property var screen: null
    property real width: 1920
    property real height: 1080
    property bool active: false
    property var world: ({width:width,floor:height-8,platforms:[],blocked:false})
    readonly property var monitor: screen ? Hyprland.monitorFor(screen) : null
    function rebuild() {
        var values=Hyprland.toplevels.values,clients=[];
        for(var i=0;i<values.length;i++)if(values[i].lastIpcObject)clients.push(values[i].lastIpcObject);
        world=World.build(clients,monitor?monitor.lastIpcObject:null,width,height);
    }
    property Timer poll: Timer {
        interval:1000;repeat:true;running:root.active;triggeredOnStart:true
        onTriggered:{Hyprland.refreshToplevels();Hyprland.refreshMonitors();root.rebuild();}
    }
    // Bursts of Hyprland events (workspace switch, drag) collapse into one rebuild.
    property Timer debounce: Timer {interval:50;onTriggered:root.rebuild()}
    property Connections changes: Connections {
        target:Hyprland
        function onRawEvent(event) {if(root.active)root.debounce.restart();}
    }
}
