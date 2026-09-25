import QtQuick
Canvas {
 id:root
 property string kind:'home'
 property color tint:'#a3b2bc'
 implicitWidth:20;implicitHeight:20
 onTintChanged:requestPaint()
 onKindChanged:requestPaint()
 onPaint:{
  var c=getContext('2d');c.reset();c.strokeStyle=tint;c.lineWidth=1.5;c.lineCap='round';c.lineJoin='round';c.beginPath();
  if(kind==='home'){c.moveTo(2,9);c.lineTo(10,2);c.lineTo(18,9);c.moveTo(4,8);c.lineTo(4,18);c.lineTo(8,18);c.lineTo(8,12);c.lineTo(12,12);c.lineTo(12,18);c.lineTo(16,18);c.lineTo(16,8);}
  else if(kind==='attributes'){c.moveTo(4,17);c.lineTo(4,11);c.moveTo(10,17);c.lineTo(10,7);c.moveTo(16,17);c.lineTo(16,3);}
  else{c.moveTo(1,10);c.lineTo(5,10);c.lineTo(8,4);c.lineTo(12,16);c.lineTo(15,10);c.lineTo(19,10);}
  c.stroke();
 }
}
