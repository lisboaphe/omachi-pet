import QtQuick
import QtQuick.Window
import Quickshell
import "src" as Pet
import "src/ui" as Ui
ShellRoot {
    property string scenario:Quickshell.env('OMACHI_TEST_SCENARIO')
    function check(value,label){if(!value)console.error('SMOKE FAILED '+label);else console.log('PASS '+label);}
    Pet.PetController {id:service;desktopSnapshot:({appClass:'spotify',musicPlaying:true,isIdle:false})}
    Ui.WindowTracker {active:false}
    Window {
        id:preview;visible:true;width:420;height:720;color:'#172435'
        Ui.PetRoom {id:room;anchors.fill:parent;service:service}
    }
    Window {
        id:barPreview;visible:true;width:50;height:40;color:'#172435'
        Pet.PetWidget {id:widget;anchors.centerIn:parent;shell:({serviceFor:function(){return service;}})}
    }
    Timer {interval:400;running:scenario==='fresh';onTriggered:preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/naming.png');})}
    Timer {
        interval:800;running:true
        onTriggered:{
            if(scenario==='corrupt'||scenario==='future'){
                check(!service.ready&&!!service.error,'CORRUPT PRESERVED');return;
            }
            check(service.ready&&!!service.pack&&!service.error,'READY');
            console.log('SMOKE LOADED STAGE '+service.pet.stage);
            check(service.barAnimation===(service.pet.stage?'slime/idle':'egg/idle'),'BAR STAGE');
            if(scenario==='migrate'){check(service.pet.name==='Luna'&&service.pet.xp===77&&service.pet.growth.mind===40&&service.pet.legacyGrowth.calm===8,'MIGRATED');}
            if(scenario==='fresh'){
                check(service.needsName&&service.pet.age===0,'NAME BEFORE LIFECYCLE');
                check(!service.namePet('   '),'EMPTY NAME REJECTED');
            }
            check(service.namePet(scenario==='migrate'?'Luna':'Puddle'),'NAME SAVED');
            check(!service.needsName,'NAME SCREEN COMPLETED');
            var p=service.copyPet();p.stage=1;p.species='slime';p.energy=80;p.hunger=85;p.sleeping=false;service.pet=p;
            check(service.barAnimation==='slime/idle','BAR HATCH');
            if(scenario==='recovery'){service.roaming=true;service.overlaySafe=false;service.recoverRoaming();check(service.travelPhase==='out','RECOVERY STARTED');}
            else if(scenario==='portal'){
                service.roaming=true;service.overlaySafe=false;service.goPlay();check(service.travelPhase==='waiting','PORTAL WAITS FOR SAFE SURFACE');
            }else{
                service.setMapping('music','mind');service.setAppCategory('test-custom-app','gaming');
                var before=service.pet.growth.mind;service.refreshActivity();service.activityElapsed=0;
                service.advanceActivity(29);check(service.pet.growth.mind===before,'NO EARLY REWARD');
                service.advanceActivity(1);check(service.pet.growth.mind>before,'MAPPED REWARD');
                check(service.animation==='slime/listen_music','MUSIC SPRITE');
                service.desktopSnapshot={appClass:'okular',musicPlaying:false,isIdle:false};service.refreshActivity();check(service.animation==='slime/read','READING SPRITE');
                var poseStart=service.lastActivityPose;service.refreshActivity();check(service.lastActivityPose===poseStart,'DETECTION DOES NOT RESTART LOOP');
                service.magicIndex=0;service.desktopSnapshot={appClass:'steam_app_123',musicPlaying:false,isIdle:false};service.refreshActivity();check(service.activityAnimation==='cast_fire','GAMING CAST START');
                service.lastActivityPose=service.now-service.duration('cast_fire')-1;check(service.activityAnimation==='idle','GAMING CAST FINISH');

                service.desktopSnapshot={appClass:'spotify',musicPlaying:true,isIdle:true};service.refreshActivity();
                var xp=service.pet.xp;service.advanceActivity(60);check(service.pet.xp===xp,'IDLE STOPS REWARDS');
                service.desktopSnapshot={appClass:'spotify',musicPlaying:true,isIdle:false};service.refreshActivity();
            }
            if(scenario==='fatigue'){var tired=service.copyPet();tired.energy=1;service.pet=tired;}
            var grown=service.copyPet();grown.growth.mind=42.5;grown.growth.power=14;grown.growth.creativity=78;grown.growth.charisma=8.5;grown.growth.adventure=28;service.pet=grown;
            service.save();
        }
    }
    Timer {interval:1100;running:scenario==='portal';onTriggered:{check(service.travelPhase==='waiting','STILL WAITING');service.overlaySafe=true;}}
    Timer {interval:1400;running:scenario==='fatigue';onTriggered:check(service.pet.sleeping&&service.reaction==='sleep_enter','AUTO SLEEP')}
    Timer {interval:2100;running:scenario==='fatigue';onTriggered:{check(service.animation==='slime/sleep_enter','SLOW SLEEP ENTRY');var rested=service.copyPet();rested.energy=95;service.pet=rested;service.reaction='';service.tick();check(service.pet.sleeping,'MINIMUM REST');rested=service.copyPet();rested.sleepElapsed=rested.sleepDuration;service.pet=rested;}}
    Timer {interval:2500;running:scenario==='fatigue';onTriggered:check(!service.pet.sleeping&&service.reaction==='wake_up','AUTO WAKE')}
    Timer {interval:1500;running:true;onTriggered:{
        preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/home.png');});
        barPreview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/bar.png');});
    }}
    Timer {interval:1900;running:scenario!=='portal';onTriggered:service.panelTab='attributes'}
    Timer {interval:2200;running:scenario!=='portal';onTriggered:preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/attributes.png');})}
    Timer {interval:2350;running:scenario==='fresh';onTriggered:service.panelTab='activities'}
    Timer {interval:2600;running:scenario==='fresh';onTriggered:preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/activities.png');})}
    Timer {interval:2700;running:scenario==='fresh';onTriggered:{service.panelTab='home';var p=service.copyPet();p.happiness=22;service.pet=p;}}
    Timer {interval:3000;running:scenario==='fresh';onTriggered:preview.contentItem.grabToImage(function(r){r.saveToFile(Quickshell.env('OMACHI_TEST_OUTPUT')+'/low-mood.png');})}
    Timer {interval:3200;running:scenario==='fresh';onTriggered:{var before=service.pet.happiness;service.act('play');check(service.reaction==='play'&&service.pet.happiness===before+5,'PLAY REACTION AND MOOD');}}
    Timer {interval:3500;running:scenario==='portal';onTriggered:{check(!service.roaming&&!service.travelling&&service.panelOpen,'PORTAL ARRIVED HOME');}}
    Timer {interval:3500;running:scenario==='recovery';onTriggered:{check(service.roaming&&!service.travelling&&service.recoverySerial===1,'RECOVERY ARRIVED');service.recoverRoaming();check(!service.travelling,'RECOVERY COOLDOWN');}}
    Timer {interval:scenario==='portal'||scenario==='recovery'?3900:scenario==='fresh'?3500:3000;running:true;onTriggered:{console.log('SMOKE STATUS '+service.saveStatus);Qt.quit();}}
}
