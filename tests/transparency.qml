import QtQuick
import QtQuick.Window
import Quickshell
import "src" as Pet
import "src/ui" as Ui
ShellRoot {
 Pet.PetController {id:service;desktopSnapshot:({appClass:'',musicPlaying:false,isIdle:false})}
 Window {
  id:preview;visible:true;width:600;height:810;color:'transparent'
  Rectangle {id:plain;anchors.fill:parent;visible:false;color:'black'}
  Item {id:backdrop;anchors.fill:parent
  Rectangle {anchors.fill:parent;gradient:Gradient {GradientStop {position:0;color:'#5c797b'} GradientStop {position:1;color:'#354661'}}}
  Rectangle {x:-100;y:190;width:800;height:145;rotation:-22;color:'#849e90';opacity:.75}
  Rectangle {x:290;y:520;width:410;height:180;radius:65;color:'#876f7f';opacity:.6}
  Text {x:20;y:16;text:'Transparency preview · simulated desktop';color:'#ecf3f3';font.pixelSize:12}
  }
  Ui.PetRoom {id:room;x:90;y:50;width:420;height:720;service:service}
 }
 Timer {interval:600;running:true;onTriggered:{service.namePet('Mo');var p=service.copyPet();p.stage=1;p.species='slime';service.pet=p;}}
 Timer {interval:1300;running:true;onTriggered:preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/transparency-preview.png');})}
 Timer {interval:1450;running:true;onTriggered:{backdrop.visible=false;plain.visible=true;plain.color='black';}}
 Timer {interval:1600;running:true;onTriggered:preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/black.png');})}
 Timer {interval:1800;running:true;onTriggered:plain.color='white'}
 Timer {interval:1950;running:true;onTriggered:preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/white.png');})}
 Timer {interval:2200;running:true;onTriggered:Qt.quit()}
}
