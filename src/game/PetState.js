var VERSION=7,HATCH_SECONDS=300,BOOST_LIMIT=240,BOOST_SPEED=10;
// Keep in sync with Activities.definitions (asserted by tests).
var ACTIVITY_IDS=['reading','writing','coding','painting','creative_writing','music','music_creation','communication','gaming','exercise','browsing','relaxing','general','idle'];
var FEED_COOLDOWN=20000,PLAY_COOLDOWN=30000,PET_COOLDOWN=15000,FULL_THRESHOLD=95,PLAY_MIN_ENERGY=5;
function finite(x,fallback){return typeof x==='number'&&isFinite(x)?x:fallback;}
function clamp(x,a,b){return Math.max(a,Math.min(b,x));}
function fresh(now){return {schemaVersion:VERSION,name:'Mochi',nameConfirmed:false,manaCharged:false,stage:0,species:'egg',age:0,phase:'idle',phaseTime:0,hunger:85,happiness:80,energy:90,health:100,affection:0,xp:0,growth:{mind:0,power:0,creativity:0,charisma:0,adventure:0},legacyGrowth:{},activityMappings:{},appCategories:{},activitySeconds:{},sleeping:false,tiredness:0,sleepElapsed:0,sleepDuration:60,activityEnabled:true,lastSaved:now,lastAction:0,lastPet:0,lastPlay:0,lastRecall:0};}
function restore(raw,now){
 if(!raw||typeof raw!=='object'||Array.isArray(raw)||[5,7].indexOf(raw.schemaVersion)<0)throw Error('Unsupported or invalid pet save; original file kept');
 var p=fresh(now);p.nameConfirmed=raw.nameConfirmed===true;p.manaCharged=raw.manaCharged===true;p.name=typeof raw.name==='string'?raw.name.slice(0,32):p.name;
 p.stage=raw.stage===1?1:0;p.species=p.stage?'slime':'egg';p.age=clamp(finite(raw.age,0),0,315360000);
 p.phase=['idle','shake','crack','hatch'].indexOf(raw.phase)>=0?raw.phase:'idle';p.phaseTime=clamp(finite(raw.phaseTime,0),0,10);
 ['hunger','happiness','energy','health','affection','tiredness'].forEach(function(k){p[k]=clamp(finite(raw[k],p[k]),0,100);});
 p.xp=clamp(finite(raw.xp,0),0,1e12);
 Object.keys(p.growth).forEach(function(k){p.growth[k]=clamp(finite(raw.growth&&raw.growth[k],0),0,1e12);});
 var calm=raw.schemaVersion===5?raw.growth&&raw.growth.calm:raw.legacyGrowth&&raw.legacyGrowth.calm;
 if(finite(calm,0)>0)p.legacyGrowth.calm=calm;
 var ids=ACTIVITY_IDS;
 ids.forEach(function(id){if(raw.activityMappings&&Object.keys(p.growth).indexOf(raw.activityMappings[id])>=0)p.activityMappings[id]=raw.activityMappings[id];p.activitySeconds[id]=clamp(finite(raw.activitySeconds&&raw.activitySeconds[id],0),0,1e12);});
 if(raw.appCategories&&typeof raw.appCategories==='object')Object.keys(raw.appCategories).slice(0,100).forEach(function(k){if(k.length<=160&&k!=='__proto__'&&k!=='constructor'&&ids.indexOf(raw.appCategories[k])>=0)p.appCategories[k.toLowerCase()]=raw.appCategories[k];});
 p.sleepElapsed=clamp(finite(raw.sleepElapsed,0),0,28800);p.sleepDuration=clamp(finite(raw.sleepDuration,60),60,900);
 p.sleeping=p.stage===1&&raw.sleeping===true;p.activityEnabled=raw.activityEnabled!==false;
 ['lastAction','lastPet','lastPlay','lastRecall'].forEach(function(k){p[k]=clamp(finite(raw[k],0),0,now);});
 if(raw.nameConfirmed!==false)advance(p,clamp((now-finite(raw.lastSaved,now))/1000,0,28800),false);p.lastSaved=now;return p;
}
function advance(p,seconds,online,resting,boost){
 seconds=clamp(finite(seconds,0),0,28800);
 var incubation=seconds;
 if(p.stage===0&&p.phase==='idle'&&p.nameConfirmed&&online&&boost&&p.age<BOOST_LIMIT){
  var fastTime=Math.min(seconds,(BOOST_LIMIT-p.age)/BOOST_SPEED);
  incubation=fastTime*BOOST_SPEED+(seconds-fastTime);
  if(p.age+incubation>=BOOST_LIMIT-1e-8)p.manaCharged=true;
 }
 p.age+=incubation;
 if(p.stage===0){
  if(online&&p.age>=HATCH_SECONDS){
   if(p.phase==='idle'){p.phase='shake';p.phaseTime=0;}
   p.phaseTime+=seconds;var duration={shake:1.8,crack:1.44,hatch:3.72};
   while(p.stage===0&&p.phaseTime>=duration[p.phase]){p.phaseTime-=duration[p.phase];if(p.phase==='shake')p.phase='crack';else if(p.phase==='crack')p.phase='hatch';else{p.stage=1;p.species='slime';p.phase='idle';p.phaseTime=0;}}
  }return;
 }
 var ticks=seconds/30;
 p.hunger=clamp(p.hunger-ticks*(p.sleeping?.08:.125),0,100);
 p.happiness=clamp(p.happiness+ticks*(p.sleeping?.1:-.05),0,100);
 p.energy=clamp(p.energy+ticks*(p.sleeping?5:resting!==false?.2:0),0,100);
 if(p.sleeping){p.sleepElapsed+=seconds;p.tiredness=clamp(p.tiredness-seconds/6,0,100);}
 // Slow care effects; no death and no passive affection farming.
 var bad=(p.hunger<10?1:0)+(p.energy<10?1:0)+(p.happiness<10?1:0);
 p.health=clamp(p.health+ticks*(bad>=2?-.1:p.hunger>40&&p.energy>40&&p.happiness>40?.03:0),0,100);
}
function action(p,name,now){
 if(p.stage===0)return '';
 if(name==='sleep'){p.sleeping=!p.sleeping;if(p.sleeping){p.sleepElapsed=0;p.sleepDuration=60+540*(.7*p.tiredness+.3*(100-p.energy))/100;}return p.sleeping?'sleep_enter':'wake_up';}
 if(p.sleeping)return '';
 if(name==='play'){if(now-p.lastPlay<PLAY_COOLDOWN||p.energy<PLAY_MIN_ENERGY)return '';p.lastPlay=now;p.happiness=clamp(p.happiness+5,0,100);p.energy=clamp(p.energy-2,0,100);p.affection=clamp(p.affection+.3,0,100);return 'play';}
 if(name==='pet'){if(now-p.lastPet<PET_COOLDOWN)return '';p.lastPet=now;p.affection=clamp(p.affection+.2,0,100);p.happiness=clamp(p.happiness+1,0,100);return 'happy';}
 if(name!=='feed'||now-p.lastAction<FEED_COOLDOWN||p.hunger>=FULL_THRESHOLD)return '';
 // A full pet refuses food, so feed-spamming cannot farm affection.
 p.lastAction=now;p.hunger=clamp(p.hunger+18,0,100);p.affection=clamp(p.affection+.5,0,100);return 'eat';
}

function setName(p,value) {
 if(typeof value!=='string')return false;
 var name=value.replace(/[\x00-\x1f\x7f]/g,'').trim();
 if(!name||name.length>32)return false;
 p.name=name;p.nameConfirmed=true;return true;
}

function eggAnimation(p,boost){
 if(p.phase==='crack'||p.phase==='hatch')return 'egg/'+p.phase;
 if(p.manaCharged&&p.age>=BOOST_LIMIT)return 'egg/shake_mana';
 if(p.phase==='shake')return 'egg/shake';
 return boost&&p.age<BOOST_LIMIT?'egg/mana':'egg/idle';
}
