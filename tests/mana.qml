import QtQuick
import QtQuick.Window
import Quickshell
import "src" as Pet
import "src/ui" as Ui
ShellRoot {
 function check(ok,label){if(!ok)console.error('MANA FAILED '+label);else console.log('PASS '+label);}
 function find(item,name){if(item.objectName===name)return item;for(var i=0;i<item.children.length;i++){var result=find(item.children[i],name);if(result)return result;}return null;}
 Pet.PetController {id:service;desktopSnapshot:({appClass:'',musicPlaying:false,isIdle:false})}
 Window {id:preview;visible:true;width:420;height:720;color:'transparent';Ui.PetRoom {id:room;anchors.fill:parent;service:service}}
 Timer {interval:600;running:true;onTriggered:{
  check(service.ready,'READY');service.namePet('Mo');var p=service.copyPet();p.stage=0;p.phase='idle';p.age=100;service.pet=p;
  var hover=find(room,'eggManaHover');check(!!hover,'EGG HOVER AREA');hover.entered();check(!service.eggBoostActive,'CLOSED PANEL CANNOT BOOST');
  service.panelOpen=true;hover.entered();check(service.eggBoostActive&&service.animation==='egg/mana','HOVER PLAYS MANA');
  var before=service.pet.age;service.lastTick=Date.now()-100;service.tick();check(service.pet.age-before>=.99&&service.pet.age-before<1.3,'10X INCUBATION');
 }}
 Timer {interval:900;running:true;onTriggered:room.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/egg-mana-preview.png');})}
 Timer {interval:1100;running:true;onTriggered:{
  var hover=find(room,'eggManaHover');hover.exited();check(!service.eggBoostActive,'LEAVE STOPS BOOST');
  service.panelOpen=false;check(!service.eggHovered,'CLOSE CLEARS HOVER');
  var p=service.copyPet();p.age=239.5;service.pet=p;service.panelOpen=true;hover.entered();service.lastTick=Date.now()-100;service.tick();
  check(!service.eggBoostActive&&service.pet.manaCharged&&service.eggRemaining<=60&&service.eggRemaining>59,'FINAL MINUTE CAP');
  check(service.animation==='egg/shake_mana','FINAL MINUTE ANIMATION');service.save();
 }}
 Timer {interval:1450;running:true;onTriggered:room.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/egg-final-minute-preview.png');})}
 Timer {interval:1700;running:true;onTriggered:{var p=service.copyPet();p.age=299.95;service.pet=p;service.lastTick=Date.now()-100;service.tick();check(service.pet.stage===0&&service.pet.phase==='shake','REVEAL STARTS');}}
 Timer {interval:8900;running:true;onTriggered:{check(service.pet.stage===1,'FULL REVEAL BECOMES SLIME');service.save();}}
 Timer {interval:9300;running:true;onTriggered:Qt.quit()}
}
