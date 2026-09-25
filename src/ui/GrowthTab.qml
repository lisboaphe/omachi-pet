pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../game/Activities.js" as Activities
Flickable {
    id:root
    required property var service
    clip:true;contentHeight:body.implicitHeight+8;boundsBehavior:Flickable.StopAtBounds
    ScrollBar.vertical:ScrollBar {policy:ScrollBar.AsNeeded}
    Column {
        id:body;width:root.width-6;spacing:9
        Text {text:'Growth';color:'#eff7f4';font.pixelSize:19;font.bold:true}
        Text {width:parent.width;text:'Five attributes. One little companion.';color:'#9bb4c0';font.pixelSize:11;wrapMode:Text.Wrap}
        Repeater {
            model:[{key:'mind',label:'Mind',tint:'#9cbced'},{key:'power',label:'Power',tint:'#efa68f'},{key:'creativity',label:'Creativity',tint:'#c9a6e8'},{key:'charisma',label:'Charisma',tint:'#ecc47e'},{key:'adventure',label:'Adventure',tint:'#8ed8c2'}]
            AttributeCard {
                required property var modelData
                width:parent.width;label:modelData.label;tint:modelData.tint;experience:root.service.pet.growth[modelData.key]
                training:root.service.pet.stage===1&&root.service.pet.activityEnabled&&!root.service.pet.sleeping&&!root.service.desktop.isIdle&&!root.service.travelling&&!root.service.reaction&&!root.service.intensiveBlocked&&root.service.growthMultiplier>0&&(Activities.gains(root.service.pet,root.service.currentActivity)[modelData.key]||0)>0
            }
        }
        Text {width:parent.width;text:'Health '+Math.round(root.service.pet.health)+' · Affection '+root.service.pet.affection.toFixed(1)+' · Tiredness '+Math.round(root.service.pet.tiredness);color:'#9bb4c0';font.pixelSize:10}
        Text {width:parent.width;text:root.service.lastGain;color:'#9bb4c0';font.pixelSize:11;wrapMode:Text.Wrap}
        Text {visible:root.service.pet.legacyGrowth.calm>0;width:parent.width;text:'Legacy Calm: '+(root.service.pet.legacyGrowth.calm||0).toFixed(1)+' XP · preserved';color:'#9bb4c0';font.pixelSize:10;wrapMode:Text.Wrap}
    }
}
