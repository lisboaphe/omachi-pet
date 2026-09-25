import QtQuick
Item {
 id:root
 property string label:''
 property real value:0
 property real share:0
 property color tint:'#94cabb'
 implicitHeight:35;implicitWidth:340
 Text {text:root.label;color:'#9cadb7';font.pixelSize:11}
 Text {anchors.right:parent.right;text:Math.round(root.value)+'%';color:'#dce5e8';font.pixelSize:11}
 Rectangle {anchors {left:parent.left;right:parent.right;bottom:parent.bottom;bottomMargin:6}height:4;radius:2;color:'#293740'
  Rectangle {width:parent.width*Math.max(0,Math.min(1,root.share));height:4;radius:2;color:root.tint}
 }
}
