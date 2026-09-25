import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Wayland
Scope {
    id:root
    property bool enabled:true
    property string appClass:''
    readonly property bool isIdle:idleMonitor.isIdle
    readonly property bool musicPlaying:{
        if(!enabled)return false;
        var players=Mpris.players.values;
        for(var i=0;i<players.length;i++)if(players[i].isPlaying)return true;
        return false;
    }
    function refresh(){
        if(!enabled){appClass='';return;}
        var top=Hyprland.activeToplevel,ipc=top?top.lastIpcObject:null;
        appClass=ipc&&typeof ipc.class==='string'?ipc.class.toLowerCase():'';
    }
    onEnabledChanged:refresh()
    IdleMonitor {id:idleMonitor;enabled:root.enabled;timeout:300;respectInhibitors:false}
    Connections {target:Hyprland;function onActiveToplevelChanged(){root.refresh();}}
    Timer {interval:1000;repeat:true;running:root.enabled;triggeredOnStart:true;onTriggered:root.refresh()}
}
