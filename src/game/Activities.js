// Detection, animation choice and training targets are deliberately independent.
var attributes=['mind','power','creativity','charisma','adventure'];
var definitions={
 reading:{label:'Reading / studying',animation:'read',growth:{mind:1},happiness:.1,energy:-.5,fullness:-.1},
 writing:{label:'Writing / notes',animation:'write',growth:{mind:1},happiness:.2,energy:-.5,fullness:-.1},
 coding:{label:'Coding / terminal',animation:'read',growth:{mind:1},happiness:0,energy:-.6,fullness:-.1},
 painting:{label:'Art / design',animation:'paint',growth:{creativity:1},happiness:.4,energy:-.5,fullness:-.1},
 creative_writing:{label:'Creative writing',animation:'write',growth:{creativity:1},happiness:.3,energy:-.5,fullness:-.1},
 music:{label:'Listening to music',animation:'listen_music',growth:{charisma:1},happiness:.8,energy:-.2,fullness:-.05},
 music_creation:{label:'Making music',animation:'listen_music',growth:{creativity:1},happiness:.5,energy:-.5,fullness:-.1},
 communication:{label:'Chat / communication',animation:'social',growth:{charisma:1},happiness:.3,energy:-.3,fullness:-.05},
 gaming:{label:'Gaming',animation:'cast_spell',growth:{adventure:.6,power:.4},happiness:.6,energy:-.8,fullness:-.1},
 exercise:{label:'Exercise',animation:'exercise',growth:{power:1},happiness:.3,energy:-1.1,fullness:-.2},
 browsing:{label:'Browsing / exploring',animation:'idle',growth:{adventure:1},happiness:.2,energy:-.3,fullness:-.05},
 relaxing:{label:'Relaxing',animation:'meditate',growth:{},happiness:.5,energy:.4,fullness:-.05},
 general:{label:'General activity',animation:'idle',growth:{},happiness:0,energy:-.1,fullness:-.05},
 idle:{label:'Away from desktop',animation:'idle',growth:{},happiness:0,energy:0,fullness:0}
};
function validActivity(id){return Object.prototype.hasOwnProperty.call(definitions,id);}
function classify(app,rules){
 app=String(app||'').toLowerCase().slice(0,160);
 if(rules&&Object.prototype.hasOwnProperty.call(rules,app)&&validActivity(rules[app]))return rules[app];
 if(/steam_app_|steam|lutris|heroic|minecraft|gamescope/.test(app))return 'gaming';
 if(/ardour|audacity|reaper|bitwig|lmms/.test(app))return 'music_creation';
 if(/krita|gimp|inkscape|blender|figma/.test(app))return 'painting';
 if(/obsidian|libreoffice-writer|logseq|joplin|notion/.test(app))return 'writing';
 if(/evince|okular|zathura|calibre|foliate/.test(app))return 'reading';
 if(/code|codium|codex|nvim|neovim|jetbrains|zed|godot|kitty|alacritty|foot|terminal|ghostty/.test(app))return 'coding';
 if(/discord|signal|slack|telegram|teams/.test(app))return 'communication';
 if(/spotify|amberol|rhythmbox|mpv|vlc|music/.test(app))return 'music';
 if(/firefox|chromium|chrome|brave|vivaldi|zen-browser/.test(app))return 'browsing';
 return 'general';
}
function detect(app,rules,musicPlaying,idle){
 if(idle)return 'idle';
 var id=classify(app,rules);
 // Actual playback takes precedence over ambiguous browsing/general use.
 if(musicPlaying && ['general','browsing','music'].indexOf(id)>=0)return 'music';
 if(id==='music'&&!musicPlaying)return 'general';
 return id;
}
function multiplier(energy,fullness){
 var m=energy>=70?1:energy>=40?.75:energy>=20?.4:energy>0?.1:0;
 return m*(fullness<=0?0:fullness<10?.5:1);
}
function gains(p,id){
 var d=definitions[id]||definitions.general,override=p.activityMappings[id];
 if(attributes.indexOf(override)>=0){var result={};result[override]=Object.keys(d.growth).reduce(function(s,k){return s+d.growth[k];},0);return result;}
 return d.growth;
}
function description(p,id){
 var g=gains(p,id),names=Object.keys(g).filter(function(k){return g[k]>0;}).map(function(k){return k.charAt(0).toUpperCase()+k.slice(1);});
 return names.length ? names.join(' + ') : 'No attribute training';
}
function animation(id,element){return id==='gaming'?'cast_'+['fire','water','wind','earth','arcane'][Math.abs(element||0)%5]:(definitions[id]||definitions.general).animation;}
function apply(p,id,backgroundMusic){
 if(!p.activityEnabled||p.stage!==1||p.sleeping||id==='idle'||!validActivity(id))return {xp:0,growth:{}};
 if(p.energy<=5&&['gaming','exercise','painting','music_creation'].indexOf(id)>=0)return {xp:0,growth:{}};
 var d=definitions[id],g=gains(p,id),m=multiplier(p.energy,p.hunger),result={xp:0,growth:{}};
 Object.keys(g).forEach(function(k){var n=g[k]*m;p.growth[k]+=n;result.growth[k]=n;});
 if(Object.keys(g).some(function(k){return g[k]>0;})&&m>0){p.xp+=1;result.xp=1;}
 p.happiness=Math.max(0,Math.min(100,p.happiness+(d.happiness+(backgroundMusic&&id!=='music'?.2:0))*(p.hunger<30?.5:1)));
 p.energy=Math.max(0,Math.min(100,p.energy+d.energy));p.hunger=Math.max(0,Math.min(100,p.hunger+d.fullness));
 p.tiredness=Math.max(0,Math.min(100,(p.tiredness||0)+Math.max(0,-d.energy)*.8));
 p.activitySeconds[id]=(p.activitySeconds[id]||0)+30;
 return result;
}
