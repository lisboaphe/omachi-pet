pragma ComponentBehavior: Bound
import QtQuick
import "../game/Progression.js" as Progression
Rectangle {
    id:root
    required property string label
    required property real experience
    property color tint:'#8ed8c2'
    property bool training:false
    readonly property var progress:Progression.progress(experience)
    implicitHeight:70;radius:16;color:training?'#b0233e35':'#a61d2832'
    border.width:0
    Column {
        anchors {fill:parent;margins:12}spacing:8
        Row {
            width:parent.width
            Text {width:parent.width-63;text:root.label;color:'#edf5f3';font.pixelSize:14;font.weight:Font.DemiBold}
            Text {width:63;horizontalAlignment:Text.AlignRight;text:'Lv. '+root.progress.level;color:root.tint;font.pixelSize:14;font.weight:Font.DemiBold}
        }
        Rectangle {
            width:parent.width;height:5;radius:3;color:'#14252f'
            Rectangle {width:parent.width*root.progress.fraction;height:parent.height;radius:3;color:root.tint;Behavior on width {NumberAnimation {duration:250}}}
        }
        Row {
            width:parent.width
            Text {width:parent.width-90;text:Progression.display(root.progress.xp)+' / '+Progression.display(root.progress.required)+' XP';color:'#b0c4cc';font.pixelSize:10}
            Text {width:90;horizontalAlignment:Text.AlignRight;text:root.training?'Training now':'Next: Lv. '+(root.progress.level+1);color:root.training?root.tint:'#859daa';font.pixelSize:10}
        }
    }
}
