import QtQuick
import Quickshell
import Quickshell.Io
import "game/PetState.js" as Model
import "game/Activities.js" as Activities
import "game/Director.js" as Director
import "assets/Pack.js" as Pack

Scope {
    id:root
    property var shell:null
    property var manifest:null
    property string omarchyPath:''
    property var pet:Model.fresh(Date.now())
    property var pack:null
    property bool ready:false
    property string error:''
    property string saveStatus:'Loading…'
    property bool roaming:false
    property bool panelOpen:false
    property string panelTab:'home'
    property string screenName:''
    property real now:Date.now()
    property real lastTick:Date.now()
    property string reaction:''
    property real reactionUntil:0
    property real reactionStarted:0
    property string currentActivity:'general'
    property real activityElapsed:0
    property real activityPoseUntil:0
    property real lastActivityPose:0
    property int magicIndex:0
    property string lastGain:'Training starts after 30 active seconds.'
    property var desktopSnapshot:null // injectable snapshot for deterministic UI tests
    readonly property var desktop:desktopSnapshot||activitySource
    readonly property string activityLabel:!pet.activityEnabled?'App reactions paused':pet.sleeping?'Sleeping':Activities.definitions[currentActivity].label
    readonly property string trainingLabel:Activities.description(pet,currentActivity)
    readonly property real growthMultiplier:Activities.multiplier(pet.energy,pet.hunger)
    readonly property bool intensiveBlocked:pet.energy<=5&&['gaming','exercise','painting','music_creation'].indexOf(currentActivity)>=0
    readonly property string activityAnimation:{
        if(!pet.activityEnabled||pet.sleeping||intensiveBlocked)return 'idle';
        var id=Activities.animation(currentActivity,magicIndex);
        return Director.activityPose(id,Pack.resolve(pack,'slime/'+id),now-lastActivityPose);
    }
    property string ambient:'idle'
    property real ambientUntil:0
    property real nextAmbient:Date.now()+12000
    property bool eggHovered:false
    readonly property bool eggBoostActive:ready&&!needsName&&panelOpen&&eggHovered&&pet.stage===0&&pet.phase==='idle'&&pet.age<Model.BOOST_LIMIT
    readonly property real eggRemaining:Math.max(0,Model.HATCH_SECONDS-pet.age)
    readonly property real eggProgress:Math.min(1,pet.age/Model.HATCH_SECONDS)
    readonly property string animation:pet.stage===0?Model.eggAnimation(pet,eggBoostActive):Director.choose(pet,reaction,activityAnimation,ambient)
    onPanelOpenChanged:if(!panelOpen)eggHovered=false
    readonly property real animationTime:pet.stage===0&&pet.phase!=='idle'?pet.phaseTime:reaction?(now-reactionStarted)/1000:-1
    readonly property string barAnimation:pet.stage===0?'egg/idle':'slime/idle'
    property string travelTarget:''
    property string travelPhase:''
    property bool overlaySafe:true
    property int recoverySerial:0
    property real lastRecovery:0
    function recoverRoaming(){
        if(!ready||!roaming||pet.sleeping||reaction||now-lastRecovery<10000)return;
        if(travelPhase==='waiting'){lastRecovery=now;beginTravel();return;}
        if(travelling)return;
        lastRecovery=now;travelTarget='recover';beginTravel();
    }
    property bool sleepAfterTravel:false
    readonly property bool travelling:travelTarget!==''
    readonly property string statusText:travelling?(travelTarget==='home'?'Coming home…':'Going exploring…'):pet.sleeping?'Resting':roaming?'Exploring your desktop':activityLabel
    readonly property string stateDir:(Quickshell.env('XDG_STATE_HOME')||Quickshell.env('HOME')+'/.local/state')+'/omachi-pet'
    readonly property var selectedScreen:{
        var screens=Quickshell.screens;
        for(var i=0;i<screens.length;i++)if(screens[i].name===screenName)return screens[i];
        return screens.length?screens[0]:null;
    }
    readonly property bool needsName:ready&&!pet.nameConfirmed
    function namePet(value){
        if(!ready)return false;
        var p=copyPet();if(!Model.setName(p,value))return false;
        pet=p;lastTick=Date.now();save();return true;
    }
    function copyPet(){return JSON.parse(JSON.stringify(pet));}
    function duration(id){var a=Pack.resolve(pack,'slime/'+id);return a?a.durations.reduce(function(x,y){return x+y;},0):1000;}
    function playEvent(id){reaction=id;reactionStarted=now;reactionUntil=now+duration(id);}
    function save(){
        if(!ready||error)return;
        var p=copyPet();p.lastSaved=Date.now();pet=p;saveStatus='Saving…';saveFile.setText(JSON.stringify(p,null,2)+'\n');
    }
    function act(name){
        if(!ready||needsName||travelling)return;
        if(name==='sleep'&&!pet.sleeping&&roaming){sleepAfterTravel=true;requestTravel('home');return;}
        var p=copyPet(),r=Model.action(p,name,Date.now());if(!r)return;
        pet=p;playEvent(r);activityElapsed=0;save();
    }
    function toggleActivity(){if(!ready)return;var p=copyPet();p.activityEnabled=!p.activityEnabled;pet=p;activityElapsed=0;lastGain=p.activityEnabled?'Training enabled.':'Training paused.';refreshActivity();save();}
    function setMapping(id,target){
        if(!ready||!Activities.validActivity(id)||(target!=='default'&&Activities.attributes.indexOf(target)<0))return;
        var p=copyPet();if(target==='default')delete p.activityMappings[id];else p.activityMappings[id]=target;pet=p;save();
    }
    function setAppCategory(app,id){
        app=String(app||'').trim().toLowerCase();
        if(!ready||!app||app.length>160||app==='__proto__'||app==='constructor'||(id!=='automatic'&&!Activities.validActivity(id)))return;
        var p=copyPet();if(id==='automatic')delete p.appCategories[app];else p.appCategories[app]=id;pet=p;refreshActivity();save();
    }
    function resetMappings(){if(!ready)return;var p=copyPet();p.activityMappings={};pet=p;save();}
    function togglePanel(name){if(name)screenName=name;panelOpen=!panelOpen;}
    function requestTravel(target){
        if(!ready||needsName||!pack||pet.stage!==1||pet.sleeping||travelling)return;
        travelTarget=target;travelPhase='waiting';activityElapsed=0;
        if(!roaming||overlaySafe)beginTravel();
    }
    function beginTravel(){travelPhase='out';playEvent('portal_out');}
    function goPlay(){requestTravel(roaming?'home':'roam');}
    function finishEvent(){
        var old=reaction;reaction='';
        if(travelPhase==='out'){
            roaming=travelTarget!=='home';if(travelTarget==='recover')recoverySerial++;else panelOpen=!roaming;travelPhase='in';playEvent('portal_in');return;
        }
        if(travelPhase==='in'){
            if(travelTarget==='home'&&now-pet.lastRecall>=60000){var p=copyPet();p.affection=Math.min(100,p.affection+.2);p.lastRecall=now;pet=p;}
            travelTarget='';travelPhase='';save();
            if(sleepAfterTravel){sleepAfterTravel=false;act('sleep');}return;
        }
        if(old==='eat'||old==='play')playEvent('happy');
    }
    function refreshActivity(){
        var id=pet.activityEnabled?Activities.detect(desktop.appClass,pet.appCategories,desktop.musicPlaying,desktop.isIdle):'general';
        if(id!==currentActivity){currentActivity=id;activityElapsed=0;activityPoseUntil=now+5000;lastActivityPose=now;}
    }
    function advanceActivity(dt){
        if(needsName||!pet.activityEnabled||pet.stage!==1||pet.sleeping||desktop.isIdle||travelling||reaction||intensiveBlocked){activityElapsed=0;return;}
        activityElapsed+=dt;
        if(activityElapsed>=30){
            activityElapsed-=30;var p=copyPet(),gain=Activities.apply(p,currentActivity,desktop.musicPlaying);pet=p;
            var parts=Object.keys(gain.growth).filter(function(k){return gain.growth[k]>0;}).map(function(k){return '+'+gain.growth[k].toFixed(2)+' '+k;});
            lastGain=parts.length?parts.join(' · ')+' · +'+gain.xp+' XP':'No growth for this activity.';save();
        }
    }
    function tick(){
        var stamp=Date.now(),dt=Math.max(0,Math.min(28800,(stamp-lastTick)/1000));lastTick=stamp;now=stamp;
        if(!ready||needsName)return;
        var p=copyPet();if(dt>1){Model.advance(p,dt,false);Model.advance(p,.1,true);activityElapsed=0;}else Model.advance(p,dt,true,desktop.isIdle||currentActivity==='general'||!pet.activityEnabled,eggBoostActive);pet=p;
        refreshActivity();if(dt<=1)advanceActivity(dt);
        if(reaction&&now>=reactionUntil)finishEvent();
        if(travelPhase==='waiting'&&overlaySafe)beginTravel();
        if(pet.stage===1&&!travelling){
            if(!pet.sleeping&&pet.energy<=2)act('sleep');
            else if(pet.sleeping&&pet.energy>=90&&pet.sleepElapsed>=pet.sleepDuration&&reaction!=='sleep_enter')act('sleep');
        }
        if(now-lastActivityPose>=12000){magicIndex=(magicIndex+1)%5;activityPoseUntil=now+5000;lastActivityPose=now;}
        if(now>=nextAmbient){ambient=Math.random()<.5?'idle_variant':'idle_variant_two';ambientUntil=now+duration(ambient);nextAmbient=now+12000+Math.random()*8000;}
        if(now>=ambientUntil)ambient='idle';
    }
    DesktopActivity {id:activitySource;enabled:root.ready&&root.pet.activityEnabled&&root.desktopSnapshot===null}
    Component.onCompleted:{
        try{pack=Pack.validate(JSON.parse(packFile.text()));}catch(e){error='Sprite pack: '+e;}
        prepare.running=true;
    }
    Component.onDestruction:save()
    FileView {id:packFile;path:Qt.resolvedUrl('../assets/pets/slime-default/pet.json');blockLoading:true}
    Process {
        id:prepare;command:['mkdir','-p',root.stateDir]
        onExited:function(code){if(code!==0){root.error='Cannot create save directory';return;}loadFile.path=root.stateDir+'/pet-v7.json';}
    }
    function loaded(raw,migrating){
        try{pet=Model.restore(JSON.parse(raw),Date.now());ready=true;saveStatus=migrating?'v0.5 pet recovered':'Saved locally';lastTick=Date.now();if(migrating)save();}
        catch(e){error='Save not loaded: '+e;saveStatus='Original save preserved';}
    }
    FileView {
        id:loadFile;printErrors:false
        onLoaded:root.loaded(text(),false)
        onLoadFailed:function(code){if(code===FileViewError.FileNotFound)legacyFile.path=root.stateDir+'/pet-v5.json';else root.error='Cannot read save file ('+code+')';}
    }
    FileView {
        id:legacyFile;printErrors:false
        onLoaded:root.loaded(text(),true)
        onLoadFailed:function(code){if(code===FileViewError.FileNotFound){root.ready=true;root.lastTick=Date.now();root.save();}else root.error='Cannot read v0.5 save ('+code+')';}
    }
    FileView {
        id:saveFile;path:root.stateDir+'/pet-v7.json';preload:false;atomicWrites:true;printErrors:false
        onSaved:root.saveStatus='Saved locally'
        onSaveFailed:root.saveStatus='Save failed — check directory permissions'
    }
    Timer {interval:100;running:true;repeat:true;onTriggered:root.tick()}
    Timer {interval:15000;running:root.ready;repeat:true;onTriggered:root.save()}
}
