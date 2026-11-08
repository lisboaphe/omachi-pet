pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
Item {
 id:root
 required property var service
 property string problem:''
 function submit(){
  if(root.service.namePet(input.text)){root.problem='';input.focus=false;}
  else root.problem='Use a name between 1 and 32 characters.';
 }
 Column {
  anchors {left:parent.left;right:parent.right;verticalCenter:parent.verticalCenter;margins:22}
  spacing:20
  Text {width:parent.width;text:'Meet your companion';color:'#eff6f2';font.pixelSize:23;font.bold:true;horizontalAlignment:Text.AlignHCenter}
  Text {width:parent.width;text:'Every little adventure starts with a name.';color:'#9db3bd';font.pixelSize:12;horizontalAlignment:Text.AlignHCenter;wrapMode:Text.Wrap}
  Item {
   width:parent.width;height:width*370/700
   Image {anchors.fill:parent;source:Qt.resolvedUrl('../../assets/backgrounds/home_grassy_lake.png');smooth:false}
   AnimatedPet {width:160;height:160;anchors {horizontalCenter:parent.horizontalCenter;bottom:parent.bottom;bottomMargin:8}pack:root.service.pack;animation:root.service.pet.stage?'slime/idle':'egg/idle';animate:root.visible}
  }
  TextField {
   id:input;objectName:'petNameInput';width:parent.width;height:46;maximumLength:32
   placeholderText:'Your pet’s name';placeholderTextColor:'#9cb1be';text:root.service.pet.name==='Mochi'?'':root.service.pet.name
   color:'#edf5f2';font.pixelSize:16;selectByMouse:true;horizontalAlignment:Text.AlignHCenter
   background:Rectangle {radius:12;color:'#22353f';border.color:input.activeFocus?'#96cab6':'#3c525d'}
   onAccepted:root.submit()
  }
  PetButton {width:parent.width;primary:true;text:'Start our adventure';enabled:input.text.trim().length>0;onClicked:root.submit()}
  Text {width:parent.width;text:root.problem||'You can change the name later in Activities.';color:root.problem?'#f2aa98':'#829da9';font.pixelSize:11;horizontalAlignment:Text.AlignHCenter;wrapMode:Text.Wrap}
  Text {width:parent.width;text:root.service.version;color:'#698390';font.pixelSize:10;horizontalAlignment:Text.AlignHCenter}
 }
}
