import QtQuick
import "../assets/Pack.js" as Pack
Item {
    id: root
    property var pack: null
    property string animation: 'egg/idle'
    property int direction: 1
    property bool animate: visible
    property bool magnify: false
    property real elapsed: 0
    // Set for egg phases so reopening a panel resumes the actual hatch phase.
    property real phaseTime: -1
    readonly property var spec: Pack.resolve(pack,animation)
    readonly property int frame: Pack.frame(spec,phaseTime>=0?phaseTime:elapsed)
    readonly property int row: spec&&spec.directions ? spec.directions[direction<0?'left':'right'] : 0
    onAnimationChanged: elapsed=0
    clip: true
    Image {
        anchors.fill:parent
        source:root.spec ? Qt.resolvedUrl('../../assets/pets/slime-default/'+root.spec.file) : ''
        sourceClipRect:Qt.rect(root.frame*96+(root.magnify?10:0),root.row*96+(root.magnify?20:0),root.magnify?76:96,root.magnify?76:96)
        smooth:false; mipmap:false
        mirror:root.direction<0 && !(root.spec&&root.spec.directions)
    }
    Timer { interval:33;repeat:true;running:root.animate;onTriggered:root.elapsed+=0.033 }
}
