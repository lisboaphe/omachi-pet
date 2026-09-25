pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../game/Activities.js" as Activities
Flickable {
    id:root
    required property var service
    contentHeight:body.implicitHeight+12
    clip:true;boundsBehavior:Flickable.StopAtBounds
    ScrollBar.vertical:ScrollBar {policy:ScrollBar.AsNeeded}
    readonly property var targets:[{label:'Default',value:'default'},{label:'Mind',value:'mind'},{label:'Power',value:'power'},{label:'Creativity',value:'creativity'},{label:'Charisma',value:'charisma'},{label:'Adventure',value:'adventure'}]
    readonly property var activityChoices:[{label:'Automatic',value:'automatic'}].concat(Object.keys(Activities.definitions).filter(function(k){return k!=='idle';}).map(function(k){return {label:Activities.definitions[k].label,value:k}
}))
    property string ruleApp:''
    property bool showTraining:false
    property bool showApps:false
    Column {
        id:body;width:root.width-8;spacing:12
        Rectangle {
            width:parent.width;height:120;radius:18;color:'#a61d2832'
            Column {
                anchors {fill:parent;margins:12}
spacing:6
                Text {text:root.service.activityLabel;color:'#e4faf3';font.pixelSize:17;font.bold:true}
                Text {text:root.service.pet.sleeping?'Training resumes after sleep':'Trains '+root.service.trainingLabel;color:'#9bdfcc';font.pixelSize:12}
                Text {width:parent.width;text:root.service.intensiveBlocked?'Too tired for this activity — time to rest':root.service.desktop.isIdle?'Paused after five minutes without input':root.service.pet.activityEnabled?'Next reward: '+Math.max(0,Math.ceil(30-root.service.activityElapsed))+'s · '+root.service.growthMultiplier.toFixed(2)+'× growth':'Automatic reactions are off';color:'#aec2cc';font.pixelSize:11;wrapMode:Text.Wrap}
                Text {width:parent.width;text:root.service.lastGain;color:'#aec2cc';font.pixelSize:11;wrapMode:Text.Wrap}
            }
        }
        Row {
            width:parent.width
            Text {width:220;anchors.verticalCenter:parent.verticalCenter;text:'Automatic app reactions';color:'#dbe9ee';font.pixelSize:12}
            Switch {id:activitySwitch
                indicator:Rectangle {implicitWidth:40;implicitHeight:24;radius:12;color:activitySwitch.checked?'#b6e7cb':'#3a4854';Rectangle {x:activitySwitch.checked?18:3;y:3;width:18;height:18;radius:9;color:activitySwitch.checked?'#16382a':'#dce5ea';Behavior on x {NumberAnimation {duration:150}}}}
                checked:root.service.pet.activityEnabled;enabled:root.service.ready;onClicked:root.service.toggleActivity()}
        }
        PetButton {width:parent.width;text:(root.showTraining?'−  ':'+  ')+'Training preferences';onClicked:root.showTraining=!root.showTraining}
        Column {width:parent.width;spacing:12;visible:root.showTraining
        Text {text:'ACTIVITY TRAINING';color:'#84cdbb';font.pixelSize:11;font.letterSpacing:1.8}
        Text {width:parent.width;text:'Choose what each activity trains. Its animation and care effects stay tied to the activity.';color:'#afc0ce';font.pixelSize:12;wrapMode:Text.Wrap}
        Repeater {
            model:Object.keys(Activities.definitions).filter(function(k){return ['general','idle','relaxing'].indexOf(k)<0;})
            Row {
                id:activityRow
                required property string modelData
                width:body.width;spacing:6
                Text {width:parent.width-152;anchors.verticalCenter:parent.verticalCenter;text:Activities.definitions[activityRow.modelData].label;color:'#dbe9ee';font.pixelSize:12;elide:Text.ElideRight}
                PetSelect {choices:root.targets;selectedValue:root.service.pet.activityMappings[activityRow.modelData]||'default';onSelected:function(value){root.service.setMapping(activityRow.modelData,value);}}
            }
        }
        PetButton {text:'Restore defaults';width:parent.width;onClicked:root.service.resetMappings()}
        }
        PetButton {width:parent.width;text:(root.showApps?'−  ':'+  ')+'Application rules';onClicked:root.showApps=!root.showApps}
        Column {width:parent.width;spacing:12;visible:root.showApps
        Text {text:'APPLICATION RULES';color:'#84cdbb';font.pixelSize:11;font.letterSpacing:1.8}
        Text {width:parent.width;text:'Assign an unfamiliar app, browser or game to an activity. Use its application class; titles and document contents are never inspected.';color:'#afc0ce';font.pixelSize:12;wrapMode:Text.Wrap}
        TextField {
            id:appInput;width:parent.width;height:36;placeholderText:'Application class, e.g. steam_app_123'
            text:root.ruleApp;color:'#e5f1f4';font.pixelSize:12
            background:Rectangle {radius:8;color:'#203546';border.color:'#4d6b7c'}
            onTextEdited:root.ruleApp=text
        }
        Row {
            spacing:8
            PetButton {width:150;text:'Use focused app';enabled:!!root.service.desktop.appClass;onClicked:root.ruleApp=root.service.desktop.appClass}
            PetSelect {
                width:184;choices:root.activityChoices;enabled:root.ruleApp.trim().length>0
                selectedValue:root.service.pet.appCategories[root.ruleApp.trim().toLowerCase()]||'automatic'
                onSelected:function(value){root.service.setAppCategory(root.ruleApp,value);}
            }
        }
        Repeater {
            model:Object.keys(root.service.pet.appCategories)
            Row {
                id:ruleRow
                required property string modelData
                width:body.width;spacing:6
                Text {width:parent.width-152;anchors.verticalCenter:parent.verticalCenter;text:ruleRow.modelData;color:'#c4d5df';font.pixelSize:11;elide:Text.ElideRight}
                PetSelect {choices:root.activityChoices;selectedValue:root.service.pet.appCategories[ruleRow.modelData]||'automatic';onSelected:function(value){root.service.setAppCategory(ruleRow.modelData,value);}}
            }
        }
        Text {width:parent.width;text:root.service.desktop.musicPlaying?'Media playback detected in the background.':'Media reacts to playback through MPRIS.';color:'#92acbd';font.pixelSize:11;wrapMode:Text.Wrap}        }
        Text {text:'Pet name';color:'#9bb4c0';font.pixelSize:12}
        Row {
            width:parent.width;spacing:8
            TextField {id:rename;width:parent.width-84;height:38;text:root.service.pet.name;maximumLength:32;color:'#edf5f2';selectByMouse:true;onAccepted:root.service.namePet(text);background:Rectangle {radius:10;color:'#263a45'}}
            PetButton {width:76;text:'Save';enabled:rename.text.trim().length>0;onClicked:root.service.namePet(rename.text)}
        }
        Text {width:parent.width;text:'Reading and music loop while active. Spells play once, then rest. Desktop poses begin after a safe landing.';color:'#91a7b2';font.pixelSize:12;wrapMode:Text.Wrap}
    }
}
