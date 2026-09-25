function choose(p,event,activity,ambient){
 if(p.stage===0)return 'egg/'+p.phase;
 if(event==='sleep_enter'||event==='wake_up'||event==='portal_out'||event==='portal_in')return 'slime/'+event;
 if(p.sleeping)return 'slime/sleep_loop';
 if(event)return 'slime/'+event;
 if(p.energy<=5)return 'slime/tired';
 if(activity&&activity!=='idle')return 'slime/'+activity;
 if(p.energy<20)return 'slime/tired';
 if(p.hunger<20||p.happiness<25)return 'slime/sad';
 return 'slime/'+(ambient||'idle');
}
function canPause(m){return ['idle','roam'].indexOf(m.state)>=0;}

// One-shot activity clips play once per scheduled window; sustained clips loop.
function activityPose(id,spec,elapsed) {
 if(!spec)return 'idle';
 if(spec.loop)return id;
 var duration=spec.durations.reduce(function(a,b){return a+b;},0);
 return elapsed>=0&&elapsed<duration?id:'idle';
}
