// Feet use monitor-local logical coordinates. UI supplies fresh platform snapshots.
function create(width,floor) { return {state:'idle',time:0,x:width/2,y:floor,vx:0,vy:0,direction:1,support:null,target:null,wait:1.5}; }
function enter(m,state) {m.state=state;m.time=0;}
function find(world,id) {return world.platforms.filter(function(p){return p.id===id;})[0] || null;}
function jump(m) {m.edgeJump=true;m.support=null;m.target=null;m.vy=-230;m.vx=m.direction*95;enter(m,'jump');}
function step(m,dt,w,rng) {
    dt=Math.max(0,Math.min(dt,0.05));rng=rng||Math.random;m.time+=dt;
    var half=Math.min(24,w.width/2), margin=Math.min(56,w.width/2), floor=w.floor, p=m.support ? find(w,m.support) : null;
    if(m.support && (!p || Math.abs(p.y-m.y)>3 || m.x<p.x1 || m.x>p.x2)) {m.support=null;m.vy=0;enter(m,'fall');}
    if((m.state==='climb'||m.state==='pull_up') && !find(w,m.target)) {m.target=null;m.vy=0;enter(m,'fall');}
    if(!m.support && ['idle','roam','edge_look','land'].indexOf(m.state)>=0 && m.y<floor-1){m.vy=0;enter(m,'fall');}
    if(m.y>floor){m.y=floor;m.support=null;enter(m,'land');}
    if(m.state==='idle') {
        if(m.time>=m.wait){enter(m,'roam');m.wait=3+rng()*5;}
    } else if(m.state==='roam') {
        m.x+=m.direction*48*dt;
        var lo=p ? p.x1+half : margin, hi=p ? p.x2-half : w.width-margin;
        if(dt>0 && ((m.x<=lo && m.direction<0) || (m.x>=hi && m.direction>0))) {m.x=Math.max(lo,Math.min(hi,m.x));enter(m,'edge_look');}
        else if(!p) {
            for(var i=0;i<w.platforms.length;i++) {
                var t=w.platforms[i],edge=m.direction>0?t.x1-half:t.x2+half;
                if(Math.abs(m.x-edge)<5 && t.bottom>=m.y-36 && t.y<m.y-70 && t.x1>=margin+half && t.x2<=w.width-margin-half && rng()<0.65) {
                    m.target=t.id;m.x=edge;m.y=Math.min(m.y,t.bottom);enter(m,'climb');break;
                }
            }
        }
        if(m.state==='roam' && m.time>m.wait){enter(m,'idle');m.wait=0.8+rng()*2;}
    } else if(m.state==='edge_look') {
        if(m.time>=0.6) {
            if(p && rng()<0.55) jump(m);
            else {m.direction=p?-m.direction:(m.x<=w.width/2?1:-1);m.x=Math.max(margin,Math.min(w.width-margin,m.x));enter(m,'roam');}
        }
    } else if(m.state==='climb') {
        var c=find(w,m.target),side=m.direction>0?c.x1-half:c.x2+half;
        if(Math.abs(m.x-side)>4){m.target=null;m.vy=0;enter(m,'fall');}
        else {m.y-=65*dt;if(m.y<=c.y+24){m.y=c.y+24;enter(m,'pull_up');}}
    } else if(m.state==='pull_up') {
        var top=find(w,m.target);
        m.y=top.y+24*(1-Math.min(1,m.time/0.9));
        m.x=m.direction>0?top.x1-half+2*half*Math.min(1,m.time/0.9):top.x2+half-2*half*Math.min(1,m.time/0.9);
        if(m.time>=0.9){m.y=top.y;m.support=top.id;m.target=null;enter(m,'idle');m.wait=0.7;}
    } else if(m.state==='jump'||m.state==='fall') {
        var previous=m.y;m.vy+=600*dt;m.y+=m.vy*dt;m.x+=m.vx*dt;
        if(m.vy>=0 && m.state==='jump')enter(m,'fall');
        if(m.vy>=0) {
            var hit=null,hitY=floor;
            w.platforms.forEach(function(s){if(m.x>=s.x1+8&&m.x<=s.x2-8&&previous<=s.y&&m.y>=s.y&&s.y<hitY){hit=s;hitY=s.y;}});
            if(m.y>=hitY){m.hardLanding=m.vy>360;m.edgeJump=false;m.y=hitY;m.support=hit?hit.id:null;m.vx=0;m.vy=0;enter(m,'land');}
        }
    } else if(m.state==='land' && m.time>=(m.hardLanding?0.77:0.6)){enter(m,'idle');m.wait=1;}
    if(m.x<margin||m.x>w.width-margin){m.x=Math.max(margin,Math.min(w.width-margin,m.x));m.direction=m.x<=margin?1:-1;m.vx=m.direction*Math.abs(m.vx);}
    return m;
}

// Watch only intended physical movement; idle/activity/sleep poses never trip recovery.
function watch(previous,m,dt,paused) {
    var moving=['roam','climb','pull_up','jump','fall'].indexOf(m.state)>=0;
    if(paused||!moving){m.stalled=0;return false;}
    var distance=Math.abs(m.x-previous.x)+Math.abs(m.y-previous.y);
    m.stalled=distance<.05?(previous.stalled||0)+dt:0;
    return m.stalled>=3;
}
function animation(m) {
    if(m.state==='jump'&&m.edgeJump)return 'edge_jump';
    if(m.state==='fall'&&m.vy>360)return 'hard_fall';
    if(m.state==='land'&&m.hardLanding)return 'hard_land';
    return m.state;
}
