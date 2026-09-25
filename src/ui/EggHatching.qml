pragma ComponentBehavior: Bound
import QtQuick
Item {
 id:root
 required property var service
 readonly property bool finalMinute:service.eggRemaining<=60
 readonly property string clock:{var s=Math.ceil(service.eggRemaining);return Math.floor(s/60)+':'+('0'+s%60).slice(-2);}
 function clearHover(){service.eggHovered=false;}
 onVisibleChanged:if(!visible)clearHover()
 Component.onDestruction:clearHover()
 Column {
  width:parent.width;spacing:22
  Item {
   width:parent.width;height:245
   Image {id:landscape;width:parent.width;height:width*370/700;source:Qt.resolvedUrl('../../assets/backgrounds/home_grassy_lake.png');smooth:false}
   Rectangle {anchors {left:parent.left;right:parent.right;bottom:landscape.bottom} height:80;gradient:Gradient {GradientStop {position:0;color:'#0010151b'} GradientStop {position:1;color:'#ff10151b'}}}
   AnimatedPet {id:egg;width:200;height:200;anchors.horizontalCenter:parent.horizontalCenter;y:0;pack:root.service.pack;animation:root.service.animation;phaseTime:root.service.animationTime;animate:root.visible}
   MouseArea {
    objectName:'eggManaHover';width:120;height:150;anchors.horizontalCenter:egg.horizontalCenter;y:38;hoverEnabled:true;enabled:root.visible&&root.service.pet.phase==='idle'
    onEntered:root.service.eggHovered=true
    onExited:root.clearHover()
    onEnabledChanged:if(!enabled)root.clearHover()
   }
   Text {anchors {horizontalCenter:parent.horizontalCenter;bottom:parent.bottom}text:root.service.pet.phase!=='idle'?'Your companion is emerging':root.finalMinute?(root.service.pet.manaCharged?'Full of mana':'Almost ready'):root.service.eggBoostActive?'Mana flowing · 10× speed':'Hover over the Egg to channel mana';color:root.service.eggBoostActive||root.service.pet.manaCharged?'#a6dfff':'#aec3cd';font.pixelSize:12}
  }
  Column {
   x:26;width:parent.width-52;spacing:14
   Row {
    width:parent.width
    Text {width:parent.width-85;text:'Hatching';color:'#edf5f3';font.pixelSize:23;font.weight:Font.Medium}
    Text {width:85;horizontalAlignment:Text.AlignRight;text:root.service.pet.phase==='idle'?root.clock:'Hatching…';color:'#b6e7cb';font.pixelSize:20}
   }
   Rectangle {width:parent.width;height:7;radius:4;color:'#34414b';Rectangle {width:parent.width*root.service.eggProgress;height:7;radius:4;color:root.service.pet.manaCharged?'#93d5ff':'#b6e7cb';Behavior on width {NumberAnimation {duration:100}}}}
   Text {width:parent.width;text:root.service.pet.phase!=='idle'?'A new adventure is about to begin.':root.finalMinute?'The final minute runs at normal speed.':root.service.eggBoostActive?'Keep hovering to fill your Egg with mana.':'Mana speeds incubation up to 10×, until 1:00 remains.';horizontalAlignment:Text.AlignHCenter;color:'#91a9b5';font.pixelSize:12;wrapMode:Text.Wrap}
  }
 }
}
