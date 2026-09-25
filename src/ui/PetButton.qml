import QtQuick
Rectangle {
 id:root
 property string text:''
 property bool primary:false
 signal clicked()
 implicitWidth:110;implicitHeight:42;radius:14
 scale:area.pressed?.97:1
 Behavior on scale {NumberAnimation {duration:90;easing.type:Easing.OutCubic}}
 Behavior on color {ColorAnimation {duration:140}}
 color:primary?(area.containsMouse?'#cef3df':'#b6e7cb'):(area.containsMouse?'#34434d':'#25333d');opacity:enabled?1:.4
 Text {anchors.centerIn:parent;width:parent.width-20;horizontalAlignment:Text.AlignHCenter;elide:Text.ElideRight;textFormat:Text.PlainText;text:root.text;color:root.primary?'#16382a':'#eaf0f1';font.pixelSize:12;font.weight:Font.Medium}
 MouseArea {id:area;anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor;onClicked:root.clicked()}
}
