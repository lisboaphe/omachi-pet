#!/usr/bin/env python3
"""Build the base pack and apply reviewed v0.8 source-sheet crops."""
import json,hashlib
from PIL import Image,ImageDraw
import build_sprites as base
ROOT=base.ROOT;OUT=base.OUT

def main():
 base.main()
 pack=json.loads((OUT/'pet.json').read_text());meta=json.loads((ROOT/'art/crops.json').read_text());frames={}
 def add(key,file,cols,ys,loop=False,ms=180,cuts=None,baseline=False,reference_width=None):
  path=ROOT/'art/source'/file;im=Image.open(path).convert('RGBA')
  # Remove transparent export noise; explicit row limits exclude printed frame numbers.
  im.putalpha(im.getchannel('A').point(lambda a:0 if a<32 else a))
  xs=cuts or [round(i*im.width/cols) for i in range(cols+1)]
  bs=[]
  for y1,y2 in ys:
   for x1,x2 in zip(xs,xs[1:]):
    b=im.crop((x1,y1,x2,y2)).getbbox()
    if not b:raise ValueError((key,x1,y1))
    bs.append((x1+b[0],y1+b[1],x1+b[2],y1+b[3]))
  scale=min(50/(reference_width or (bs[0][2]-bs[0][0])),86/max(max(b[2]-b[0],b[3]-b[1]) for b in bs))
  result=[]
  for i,b in enumerate(bs):
   crop=im.crop(b);crop=crop.resize((max(1,round(crop.width*scale)),max(1,round(crop.height*scale))),Image.Resampling.NEAREST)
   offset=round((max(q[3] for q in bs)-b[3])*scale) if baseline else 0
   f=Image.new('RGBA',(96,96));f.alpha_composite(crop,((96-crop.width)//2,90-crop.height-offset));result.append(f)
  write(key,result,loop,ms)
  meta['slime/'+key]={'source':file,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'crops':bs,'scale':scale,'baselineAligned':baseline}
 def write(key,result,loop,ms):
  sheet=Image.new('RGBA',(96*len(result),96))
  for i,f in enumerate(result):sheet.paste(f,(96*i,0))
  sheet.save(OUT/('slime/'+key+'.png'));frames[key]=result
  pack['animations']['slime/'+key]={'file':'slime/'+key+'.png','frames':len(result),'rows':1,'frameWidth':96,'frameHeight':96,'anchor':[48,90],'durations':[ms]*len(result),'loop':loop}
 def derive(key,source,indices,loop,ms):
  write(key,[frames[source][i] for i in indices],loop,ms)
  meta['slime/'+key]={'derivedFrom':'slime/'+source,'frameIndices':indices}
 add('read','Slime_Loop_reading.png',9,[(110,351),(410,628)],True,260)
 add('listen_music','Slime_Loop_music.png',8,[(140,335),(398,590)],True,260)
 add('eat','Slime_Action_Eating.png',8,[(140,350),(390,595)],False,180)
 add('sleep_enter','Slime_Action_Sleeping.png',8,[(0,682)],False,300)
 derive('sleep_loop','sleep_enter',[6,7],True,900)
 for key,file in [('idle_variant','Slime_Action_Variant_Iddle.png'),('idle_variant_two','Slime_Action_Variant_Iddle2.png')]:add(key,file,8,[(0,682)],False,220)
 add('edge_jump','Slime_Action_JumpionOfEdge.png',8,[(0,682)],False,65)
 add('hard_fall','Slime_Action_LandingFastFalling.png',7,[(0,672)],False,90,reference_width=175)
 add('hard_land','Slime_Action_LandingFastFalling.png',7,[(673,866)],False,110,reference_width=175)
 add('come_home','Slime_Action_ComeHome_Vortex.png',20,[(280,435)],False,90,baseline=True)
 derive('portal_out','come_home',list(range(12)),False,90)
 derive('portal_in','come_home',list(range(12,20)),False,135)
 xs=[0,146,285,429,571,721,875,1035,1194,1354,1536,1717,1886,2048]
 for key,limits in zip(['wind','water','fire','earth','arcane'],[(0,155),(155,280),(280,414),(414,540),(540,682)]):
  add('cast_'+key,'Slime_Loop_Casting.png',13,[limits],False,140,cuts=xs)
 pack['version']='1.0.0'
 (OUT/'pet.json').write_text(json.dumps(pack,indent=2)+'\n');(ROOT/'art/crops.json').write_text(json.dumps(meta,indent=2)+'\n')
 contact=Image.new('RGB',(1250,120*len(frames)),'#202f3b');d=ImageDraw.Draw(contact)
 for i,(key,fs) in enumerate(frames.items()):
  d.text((8,120*i+4),key,fill='white')
  for j,f in enumerate(fs):
   f=f.resize((60,60),Image.Resampling.NEAREST);contact.paste(f,(8+j*61,120*i+25),f)
 contact.save(ROOT/'docs/v8-sprite-contact.png')
if __name__=='__main__':main()
