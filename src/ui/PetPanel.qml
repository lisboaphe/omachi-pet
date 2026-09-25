import QtQuick
import Quickshell
import Quickshell.Wayland
PanelWindow {
    id: root
    required property var service
    anchors { right:true;top:true }
    margins {right:20;top:52}
    implicitWidth:420;implicitHeight:720
    color:'transparent';exclusionMode:ExclusionMode.Ignore
    WlrLayershell.layer:WlrLayer.Overlay
    WlrLayershell.namespace:'omachi-panel'
    WlrLayershell.keyboardFocus:WlrKeyboardFocus.OnDemand
    PetRoom {anchors.fill:parent;service:root.service}
}
