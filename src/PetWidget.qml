import QtQuick
import Quickshell
import "ui"
Item {
    id:root
    property var bar:null
    property var shell:null
    property string moduleName:'community.omachi-pet'
    property var settings:({})
    readonly property var service:bar&&bar.shell?bar.shell.serviceFor(moduleName):shell?shell.serviceFor(moduleName):null
    readonly property var hostWindow:root.QsWindow.window
    readonly property int iconSize:Math.max(24,Math.min(40,bar?bar.barSize:32))
    implicitWidth:iconSize+8
    implicitHeight:bar?bar.barSize:32
    AnimatedPet {
        anchors.centerIn:parent;width:root.iconSize;height:root.iconSize
        pack:root.service?root.service.pack:null
        animation:root.service?root.service.barAnimation:'egg/idle'
        magnify:true
    }
    MouseArea {
        anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor
        onClicked:if(root.service)root.service.togglePanel(root.hostWindow&&root.hostWindow.screen?root.hostWindow.screen.name:'')
        onEntered:if(root.bar&&typeof root.bar.showTooltip==='function')root.bar.showTooltip(root,root.service?(root.service.pet.stage?'Slime':'Egg')+' · '+root.service.statusText:'Pet loading')
        onExited:if(root.bar&&typeof root.bar.hideTooltip==='function')root.bar.hideTooltip(root)
    }
}
