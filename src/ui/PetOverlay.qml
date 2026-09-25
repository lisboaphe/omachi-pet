import QtQuick
import Quickshell
import Quickshell.Wayland
import "../game/Movement.js" as Movement
import "../game/Director.js" as Director
PanelWindow {
    id:root
    required property var service
    anchors {left:true;right:true;top:true;bottom:true}
    color:'transparent';exclusionMode:ExclusionMode.Ignore
    WlrLayershell.layer:WlrLayer.Top
    WlrLayershell.namespace:'omachi-roaming'
    WlrLayershell.keyboardFocus:WlrKeyboardFocus.None
    mask:Region {x:pet.x;y:pet.y;width:pet.visible?pet.width:0;height:pet.visible?pet.height:0}
    property var motion: Movement.create(width,height-8)
    property real lastTick: Date.now()
    readonly property bool posePaused:(service.travelTarget==='recover'||Director.canPause(motion))&&(service.reaction!==''||service.pet.sleeping||service.activityAnimation!=='idle'||service.ambient!=='idle')
    readonly property string poseAnimation:posePaused?service.animation:'slime/'+Movement.animation(motion)
    function resetMotion(){
        if(!tracker)return;
        tracker.rebuild();motion=Movement.create(width,Math.max(0,tracker.world.floor));lastTick=Date.now();
    }
    Connections {target:root.service;function onRecoverySerialChanged(){root.resetMotion();var m=JSON.parse(JSON.stringify(root.motion));m.x=root.width*.2;m.direction=1;root.motion=m;}}
    onVisibleChanged: if(visible)resetMotion()
    onScreenChanged: resetMotion()
    onWidthChanged: if(visible)resetMotion()
    onHeightChanged: if(visible)resetMotion()
    WindowTracker {id:tracker;screen:root.screen;width:root.width;height:root.height;active:root.visible}
    Item {
        id:pet
        width:112;height:112
        x:Math.max(0,Math.min(root.width-width,root.motion.x-width/2));y:Math.max(0,Math.min(root.height-height,root.motion.y-height*90/96))
        visible:!tracker.world.blocked
        AnimatedPet {anchors.fill:parent;pack:root.service.pack;animation:root.poseAnimation;phaseTime:root.posePaused?root.service.animationTime:-1;direction:root.motion.direction;animate:root.visible&&pet.visible}
        MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.service.panelOpen=true}
    }
    Timer {
        interval:16;repeat:true;running:root.visible
        onTriggered:{
            var now=Date.now(),dt=Math.min(0.05,Math.max(0,(now-root.lastTick)/1000));root.lastTick=now;
            if(tracker.world.blocked){root.service.overlaySafe=true;return;}
            var m=JSON.parse(JSON.stringify(root.motion));
            Movement.step(m,0,tracker.world);
            var pause=(root.service.travelTarget==='recover'||Director.canPause(m))&&(root.service.reaction!==''||root.service.pet.sleeping||root.service.activityAnimation!=='idle'||root.service.ambient!=='idle');
            Movement.step(m,pause?0:dt,tracker.world);var stuck=Movement.watch(root.motion,m,dt,pause);root.motion=m;if(stuck)root.service.recoverRoaming();root.service.overlaySafe=Director.canPause(m);
        }
    }
}
