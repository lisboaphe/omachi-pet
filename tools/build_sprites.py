#!/usr/bin/env python3
"""Reproducible alpha crops. Requires Pillow only at build time."""
import hashlib,json
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/pets/slime-default'
SPECS={'egg/crack':('EGG_Hatching.png',6,1),'egg/hatch':('Egg_hatch.png',6,1),'slime/idle':('Slime_New_Idle.png',4,1),'slime/roam':('Slime_New_Roaming.png',4,4),'slime/edge_look':('Slime_New_Edge.png',4,1),'slime/climb':('Slime_New_Climbing.png',6,1),'slime/pull_up':('Slime_New_pullingup.png',6,1),'slime/jump':('Slime_New_jumping.png',6,1),'slime/fall':('Slime_New_falling.png',4,1),'slime/land':('Slime_New_landing.png',4,1)}

NEW_SPECS={
 'slime/cast_earth':('Slime_magic_Earth.png',12,1),
 'slime/cast_fire':('Slime_magic_Fire.png',12,1),
 'slime/cast_water':('Slime_magic_Water.png',12,1),
 'slime/cast_wind':('Slime_magic_Wind.png',11,1),
 'slime/come_home':('Slime_comingHome_Vortex.png',12,1),
 'slime/eat':('Slime_eating.png',8,1),
 'slime/listen_music':('Slime_Music.png',6,1),
 'slime/read':('Slime_Reading.png',6,1),
 'slime/sleep_enter':('Slime_sleeping.png',6,1),
 'slime/wake_up':('Slime_walkingup.png',6,1),
}
SPECS.update(NEW_SPECS)
# Hand-reviewed column boundaries keep overlapping magic particles with their pose.
CUTS={
 'slime/cast_earth':[0,176,335,496,662,838,1018,1200,1376,1548,1719,1879,2048],
 'slime/cast_fire':[0,179,344,515,687,855,1025,1195,1374,1550,1719,1881,2048],
 'slime/cast_water':[0,177,344,514,685,857,1028,1200,1372,1544,1711,1875,2048],
 'slime/cast_wind':[0,184,359,536,738,939,1146,1331,1510,1693,1867,2048],
 'slime/come_home':[0,178,348,522,701,873,1024,1192,1364,1543,1710,1873,2048],
 'slime/eat':[0,246,486,727,1040,1306,1551,1787,2048],
 'slime/listen_music':[0,361,696,1028,1352,1702,2048],
 'slime/read':[0,364,684,1005,1327,1660,2048],
 'slime/sleep_enter':[0,339,674,1012,1353,1693,2048],
 'slime/wake_up':[0,354,698,1041,1380,1708,2048],
}

def runs(vals):
 result=[];start=None
 for i,v in enumerate(vals+[False]):
  if v and start is None:start=i
  if not v and start is not None:result.append((start,i));start=None
 return result

def boxes(im,cols,rows):
 # Rank whitespace gaps so detached droplets/shell pieces stay with their pose.
 a=im.getchannel('A').point(lambda p:255 if p>24 else 0)
 def partitions(axis,n):
  length=im.width if axis==0 else im.height
  used=[a.crop((i,0,i+1,im.height) if axis==0 else (0,i,im.width,i+1)).getbbox() is not None for i in range(length)]
  occupied=runs(used);lo=occupied[0][0];hi=occupied[-1][1]
  gaps=[(occupied[i][1],occupied[i+1][0]) for i in range(len(occupied)-1)]
  gaps=sorted(sorted(gaps,key=lambda b:b[1]-b[0],reverse=True)[:n-1])
  cuts=[lo]+[(x+y)//2 for x,y in gaps]+[hi]
  assert len(cuts)==n+1
  return list(zip(cuts,cuts[1:]))
 ys=partitions(1,rows);result=[]
 for y1,y2 in ys:
  strip=im.crop((0,y1,im.width,y2))
  if rows>1:
   sub=boxes(strip,cols,1);result.extend([(x,y+y1,r,b+y1) for x,y,r,b in sub]);continue
  for x1,x2 in partitions(0,cols):
   b=a.crop((x1,y1,x2,y2)).getbbox();result.append((x1+b[0],y1+b[1],x1+b[2],y1+b[3]))
 return result

def main():
 OUT.mkdir(parents=True,exist_ok=True);animations={};provenance={};allframes={}
 for key,(file,cols,rows) in SPECS.items():
  p=ROOT/'art/source'/file;im=Image.open(p).convert('RGBA')
  if key in CUTS:
   alpha=im.getchannel('A').point(lambda v:255 if v>24 else 0);bounds=alpha.getbbox();bs=[]
   cuts=CUTS[key];assert len(cuts)==cols+1,(key,cuts)
   for x1,x2 in zip(cuts,cuts[1:]):
    b=alpha.crop((x1,0,x2,im.height)).getbbox();bs.append((x1+b[0],b[1],x1+b[2],b[3]))
  else:bs=boxes(im,cols,rows)
  # One scale per sheet preserves squash/stretch and relative frame sizes.
  reference=bs[-1] if key=="slime/land" else bs[0]
  scale=min(50/(reference[2]-reference[0]),86/max(max(b[2]-b[0],b[3]-b[1]) for b in bs))
  frames=[]
  for b in bs:
   crop=im.crop(b);crop=crop.resize((max(1,round(crop.width*scale)),max(1,round(crop.height*scale))),Image.Resampling.NEAREST)
   frame=Image.new('RGBA',(96,96));frame.alpha_composite(crop,((96-crop.width)//2,90-crop.height-round((max(q[3] for q in bs)-b[3])*scale) if key in NEW_SPECS else 90-crop.height));frames.append(frame)
  allframes[key]=frames
  sheet=Image.new('RGBA',(cols*96,rows*96))
  for i,f in enumerate(frames):sheet.paste(f,((i%cols)*96,(i//cols)*96))
  target=OUT/(key+'.png');target.parent.mkdir(parents=True,exist_ok=True);sheet.save(target)
  anim={'file':key+'.png','frames':cols,'rows':rows,'frameWidth':96,'frameHeight':96,'anchor':[48,90],'durations':[150]*cols,'loop':key.split('/')[-1] not in ['hatch','crack','pull_up','jump','land','edge_look']}
  if key in NEW_SPECS:anim['loop']=key in ['slime/read','slime/listen_music'];anim['durations']=[180]*cols
  if key=='egg/hatch':anim['durations']=[140,140,160,170,180,500]
  if rows==4:anim['directions']={'down':0,'right':1,'up':2,'left':3}
  animations[key]=anim;provenance[key]={'source':file,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'crops':bs,'scale':scale}
 # Sleep uses the last three poses; travel plays both halves across surfaces.
 for key,source,indices,loop in [('slime/sleep_loop','slime/sleep_enter',[3,4,5],True),('slime/portal_out','slime/come_home',list(range(6)),False),('slime/portal_in','slime/come_home',list(range(6,12)),False)]:
  frames=[allframes[source][i] for i in indices];sheet=Image.new('RGBA',(96*len(frames),96))
  for i,f in enumerate(frames):sheet.paste(f,(i*96,0))
  sheet.save(OUT/(key+'.png'));a=dict(animations[source]);a.update(file=key+'.png',frames=len(frames),rows=1,loop=loop,durations=[240 if loop else 180]*len(frames));animations[key]=a
  provenance[key]={'derivedFrom':source,'frameIndices':indices}
 # Derivatives explicitly recorded; no invented source animation claims.
 egg=allframes['egg/crack'][0]
 for key,angles in [('egg/idle',[0,-2,0,2]),('egg/shake',[0,-6,5,-5,6,0])]:
  sheet=Image.new('RGBA',(96*len(angles),96))
  for i,angle in enumerate(angles):sheet.paste(egg.rotate(angle,Image.Resampling.NEAREST,center=(48,90)),(i*96,0))
  sheet.save(OUT/(key+'.png'));animations[key]={'file':key+'.png','frames':len(angles),'rows':1,'frameWidth':96,'frameHeight':96,'anchor':[48,90],'durations':[220 if 'idle' in key else 100]*len(angles),'loop':True};provenance[key]={'derivedFrom':'egg/crack frame 0','rotationDegrees':angles}
 pack={'schemaVersion':1,'id':'slime-default','name':'Blue Slime','version':'1.0.0','movement':{'roam':True,'climb':True,'jump':True},'animations':animations,'fallbacks':{'slime/sleep':'slime/sleep_loop','slime/happy':'slime/jump','slime/sad':'slime/idle','slime/tired':'slime/idle','slime/play':'slime/jump','slime/paint':'slime/read','slime/write':'slime/read','slime/social':'slime/listen_music','slime/meditate':'slime/idle','slime/exercise':'slime/cast_earth'}}
 (OUT/'pet.json').write_text(json.dumps(pack,indent=2)+'\n');(ROOT/'art/crops.json').write_text(json.dumps(provenance,indent=2)+'\n')
 contact=Image.new('RGB',(1200,130*len(animations)),'#202a3b');d=ImageDraw.Draw(contact)
 for i,(key,a) in enumerate(animations.items()):
  d.text((8,i*130+4),key,fill='white');sheet=Image.open(OUT/a['file']);contact.paste(sheet.crop((0,0,sheet.width,96)),(8,i*130+25),sheet.crop((0,0,sheet.width,96)))
 contact.save(ROOT/'docs/sprite-contact.png')
if __name__=='__main__':main()
