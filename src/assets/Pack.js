function validate(p) {
    if(!p || p.schemaVersion!==1 || !p.animations)throw Error('Invalid sprite pack');
    ['egg/idle','egg/shake','egg/crack','egg/hatch','slime/idle','slime/roam','slime/edge_look','slime/climb','slime/pull_up','slime/jump','slime/fall','slime/land'].forEach(function(k){if(!p.animations[k])throw Error('Missing '+k);});
    Object.keys(p.animations).forEach(function(k){
        var a=p.animations[k];
        if(!/^(egg|slime)\/[a-z_]+\.png$/.test(a.file)||!(a.frames>=1&&a.frames<=32)||a.frames%1||!(a.rows>=1&&a.rows<=4)||a.rows%1||a.frameWidth!==96||a.frameHeight!==96||!a.durations||a.durations.length!==a.frames||a.durations.some(function(d){return typeof d!=='number'||!isFinite(d)||d<16||d>5000;}))throw Error('Invalid animation '+k);
        if(!a.anchor || a.anchor[0]!==48 || a.anchor[1]!==90 || typeof a.loop!=='boolean')throw Error('Invalid anchor/loop '+k);
        if(a.directions)Object.keys(a.directions).forEach(function(d){var row=a.directions[d];if(typeof row!=='number'||row%1||row<0||row>=a.rows)throw Error('Invalid direction '+k);});
    });
    Object.keys(p.fallbacks||{}).forEach(function(k){if(!p.animations[p.fallbacks[k]])throw Error('Invalid fallback '+k);});
    return p;
}
function resolve(pack,key) {return pack ? pack.animations[key] || pack.animations[(pack.fallbacks||{})[key]] || pack.animations['slime/idle'] : null;}
function frame(a,seconds) {
    if(!a)return 0;var total=a.durations.reduce(function(x,y){return x+y;},0),time=Math.max(0,seconds*1000);
    if(a.loop)time%=total;else time=Math.min(total-1,time);
    for(var i=0;i<a.frames;i++){if(time<a.durations[i])return i;time-=a.durations[i];}return a.frames-1;
}
