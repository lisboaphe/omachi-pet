pragma ComponentBehavior: Bound
import QtQuick
Rectangle {
 id:root
 required property var service
 implicitWidth:420;implicitHeight:720
 radius:30;border.color:'#384f5963';border.width:1
 color:'transparent'
 Rectangle {anchors.fill:parent;radius:root.radius;opacity:.60;gradient:Gradient {GradientStop {position:0;color:'#10151b'} GradientStop {position:1;color:'#121c24'}}}
 readonly property bool lowMood:service.pet.happiness<35
 readonly property bool canCare:service.ready&&!service.needsName&&service.pet.stage===1&&!service.pet.sleeping&&!service.travelling
 NameSetup {anchors.fill:parent;service:root.service;visible:root.service.needsName;z:3}
 Item {
  anchors.fill:parent;visible:!root.service.needsName
  Row {
   x:24;y:24;spacing:10
   Rectangle {
    width:8;height:8;radius:4;anchors.verticalCenter:parent.verticalCenter;color:root.lowMood?'#e4bb7b':root.service.pet.sleeping?'#8c9cbb':'#b5ebcd'
    Rectangle {anchors.centerIn:parent;width:16;height:16;radius:8;color:parent.color;opacity:.12}
   }
   Text {width:root.width-110;text:root.service.pet.name;textFormat:Text.PlainText;elide:Text.ElideRight;color:'#edf5f3';font.pixelSize:26;font.weight:Font.Medium}
  }
  PetButton {anchors {right:parent.right;top:parent.top;rightMargin:19;topMargin:22} width:32;implicitHeight:32;radius:16;text:'×';color:'#162c3b47';onClicked:root.service.panelOpen=false}
  Item {
   id:body;anchors {left:parent.left;right:parent.right;top:parent.top;topMargin:78;bottom:parent.bottom;bottomMargin:root.service.pet.stage===0?60:108}
   EggHatching {anchors.fill:parent;service:root.service;visible:root.service.pet.stage===0}
   Item {
    anchors.fill:parent;opacity:root.service.pet.stage===1&&root.service.panelTab==='home'?1:0;visible:opacity>0;enabled:root.service.pet.stage===1&&root.service.panelTab==='home'
    Behavior on opacity {NumberAnimation {duration:180;easing.type:Easing.OutCubic}}
    Column {
     width:parent.width;spacing:14
     Item {
      width:parent.width;height:230
      Image {id:landscape;width:parent.width;height:width*370/700;source:Qt.resolvedUrl('../../assets/backgrounds/home_grassy_lake.png');smooth:false;mipmap:false;fillMode:Image.PreserveAspectFit}
      Rectangle {anchors {left:parent.left;right:parent.right;bottom:landscape.bottom} height:90;gradient:Gradient {GradientStop {position:0;color:'#0010151b'} GradientStop {position:1;color:'#ff10151b'}}}
      Rectangle {width:78;height:8;radius:4;anchors.horizontalCenter:parent.horizontalCenter;y:172;color:'#203428';opacity:.22;visible:!root.service.roaming||root.service.travelPhase==='in'}
      AnimatedPet {
       width:190;height:190;x:(parent.width-width)/2;y:0
       pack:root.service.pack;animation:root.service.animation;phaseTime:root.service.animationTime
       visible:!root.service.roaming||root.service.travelPhase==='in';animate:root.visible&&root.service.panelTab==='home'
       MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.service.act('pet')}
      }
      Text {anchors {horizontalCenter:parent.horizontalCenter;bottom:parent.bottom;bottomMargin:6} text:root.service.statusText;color:'#bfcec9';font.pixelSize:11}
     }
     Row {
      x:24;width:parent.width-48;height:52;spacing:18
      Repeater {
       model:[{key:'hunger',label:'Fullness',tint:'#b8d2c5'},{key:'happiness',label:'Happiness',tint:root.lowMood?'#e4bb7b':'#b7bfdd'},{key:'energy',label:'Energy',tint:'#b5ebcd'}]
       Column {
        id:statItem
        required property var modelData
        width:(root.width-84)/3;spacing:6
        Text {text:parent.modelData.label;color:'#91a2ad';font.pixelSize:10}
        Text {text:Math.round(root.service.pet[parent.modelData.key])+'%';color:parent.modelData.key==='happiness'&&root.lowMood?'#e4bb7b':'#edf5f3';font.pixelSize:20;font.weight:Font.Medium}
        Rectangle {width:parent.width;height:3;radius:2;color:'#28333d';Rectangle {width:parent.width*Math.max(0,Math.min(1,root.service.pet[statItem.modelData.key]/100));height:3;radius:2;color:statItem.modelData.tint;Behavior on width {NumberAnimation {duration:200}}}}
       }
      }
     }
     PetButton {
      x:24;width:parent.width-48;implicitHeight:48;primary:true
      text:root.service.now-root.service.pet.lastPlay<30000?'Play again in '+Math.ceil((30000-root.service.now+root.service.pet.lastPlay)/1000)+'s':'Play with '+root.service.pet.name
      enabled:root.canCare&&!root.service.reaction&&root.service.pet.energy>=5&&root.service.now-root.service.pet.lastPlay>=30000
      onClicked:root.service.act('play')
     }
     Row {
      x:24;width:parent.width-48;spacing:8
      PetButton {width:(parent.width-16)/3;implicitHeight:36;text:'Feed';enabled:root.canCare&&root.service.now-root.service.pet.lastAction>=20000;onClicked:root.service.act('feed')}
      PetButton {width:(parent.width-16)/3;implicitHeight:36;text:root.service.pet.sleeping?'Wake':'Sleep';enabled:root.service.ready&&root.service.pet.stage===1&&!root.service.travelling;onClicked:root.service.act('sleep')}
      PetButton {width:(parent.width-16)/3;implicitHeight:36;text:root.service.roaming?'Come home':'Explore';enabled:root.canCare;onClicked:root.service.goPlay()}
     }
     Text {
      x:24;width:parent.width-48;horizontalAlignment:Text.AlignHCenter;wrapMode:Text.Wrap;font.pixelSize:11
      text:root.service.error||(root.service.pet.stage===0?'Hatches in '+Math.max(0,Math.ceil((300-root.service.pet.age)/60))+' min':root.lowMood?'A little play would lift their spirits.':root.service.pet.sleeping?'Resting and recharging.':root.service.trainingLabel==='No attribute training'?'A quiet moment together.':'Growing '+root.service.trainingLabel)
      color:root.service.error?'#f0a298':root.lowMood?'#d7b786':'#7d939d'
     }
    }
   }
   GrowthTab {anchors {fill:parent;leftMargin:24;rightMargin:24} opacity:root.service.pet.stage===1&&root.service.panelTab==='attributes'?1:0;visible:opacity>0;enabled:root.service.panelTab==='attributes';service:root.service;Behavior on opacity {NumberAnimation {duration:180}}}
   ActivityTab {anchors {fill:parent;leftMargin:24;rightMargin:24} opacity:root.service.pet.stage===1&&root.service.panelTab==='activities'?1:0;visible:opacity>0;enabled:root.service.panelTab==='activities';service:root.service;Behavior on opacity {NumberAnimation {duration:180}}}
  }
  Text {anchors {bottom:parent.bottom;horizontalCenter:parent.horizontalCenter;bottomMargin:root.service.pet.stage===0?24:93} text:'v1.0.0 · '+root.service.saveStatus;color:'#67808b';font.pixelSize:9}
  Rectangle {
   id:navigation;visible:root.service.pet.stage===1;anchors {left:parent.left;right:parent.right;bottom:parent.bottom;margins:18} height:66;radius:23;color:'#c71d2932';border.color:'#34495760'
   Rectangle {x:6+(navigation.width-12)/3*(root.service.panelTab==='home'?0:root.service.panelTab==='attributes'?1:2);y:6;width:(parent.width-12)/3;height:54;radius:18;color:'#b827443d';border.color:'#426553';Behavior on x {NumberAnimation {duration:220;easing.type:Easing.OutCubic}}}
   Row {
    anchors {fill:parent;margins:6}
    Repeater {
     model:[{key:'home',title:'Home'},{key:'attributes',title:'Growth'},{key:'activities',title:'Activities'}]
     Item {
      id:navItem
      required property var modelData
      width:(navigation.width-12)/3;height:54
      Column {
       anchors.centerIn:parent;spacing:4
       NavIcon {anchors.horizontalCenter:parent.horizontalCenter;kind:navItem.modelData.key;tint:root.service.panelTab===navItem.modelData.key?'#c6f3d7':'#879ca8'}
       Text {anchors.horizontalCenter:parent.horizontalCenter;text:navItem.modelData.title;color:root.service.panelTab===navItem.modelData.key?'#c6f3d7':'#879ca8';font.pixelSize:10}
      }
      MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.service.panelTab=navItem.modelData.key}
     }
    }
   }
  }
 }
}
