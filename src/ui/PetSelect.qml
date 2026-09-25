import QtQuick
import QtQuick.Controls
ComboBox {
    id:root
    property var choices:[]
    property string selectedValue:''
    signal selected(string value)
    model:choices;textRole:'label';valueRole:'value'
    implicitHeight:34;implicitWidth:146
    font.pixelSize:12
    currentIndex:{for(var i=0;i<choices.length;i++)if(choices[i].value===selectedValue)return i;return 0;}
    onActivated:function(index){selected(choices[index].value);}
    background:Rectangle {radius:8;color:'#294254';border.color:root.activeFocus?'#8bdcc5':'#4d6b7c'}
    contentItem:Text {leftPadding:10;rightPadding:22;text:root.displayText;color:'#eaf4f8';font:root.font;verticalAlignment:Text.AlignVCenter;elide:Text.ElideRight}
    indicator:Text {x:root.width-20;y:8;text:'⌄';color:'#9cd6cb'}
}
