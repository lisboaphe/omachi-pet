pragma ComponentBehavior: Bound
import QtQuick
Rectangle {
 id:root
 required property string label
 required property real value
 property color tint:'#b6e7cb'
 implicitHeight:87;radius:16;color:'#1d2832'
 Column {
  anchors {fill:parent;margins:13} spacing:7
  Text {text:root.label;color:'#9daeb9';font.pixelSize:10;font.weight:Font.Medium}
  Text {text:Math.round(root.value)+'%';color:'#f0f5f7';font.pixelSize:23;font.weight:Font.DemiBold}
  Rectangle {width:parent.width;height:3;radius:2;color:'#34424c'
   Rectangle {width:parent.width*Math.max(0,Math.min(1,root.value/100));height:3;radius:2;color:root.tint;Behavior on width {NumberAnimation {duration:180}}}
  }
 }
}
