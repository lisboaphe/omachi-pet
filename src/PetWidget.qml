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
    Rectangle {
        visible:!!root.service&&root.service.needsCare
        width:7;height:7;radius:4;color:'#e4bb7b';border.color:'#10151b';border.width:1
        anchors {right:parent.right;top:parent.top;rightMargin:3;topMargin:Math.max(2,(parent.height-root.iconSize)/2)}
    }
    MouseArea {
        anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor
        onClicked:if(root.service)root.service.togglePanel(root.hostWindow&&root.hostWindow.screen?root.hostWindow.screen.name:'')
        onEntered:if(root.bar&&typeof root.bar.showTooltip==='function')root.bar.showTooltip(root,root.service?root.service.barTooltip:'Pet loading')
        onExited:if(root.bar&&typeof root.bar.hideTooltip==='function')root.bar.hideTooltip(root)
    }
}
