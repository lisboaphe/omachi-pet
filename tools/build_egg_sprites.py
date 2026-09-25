#!/usr/bin/env python3
"""Rebuild the complete pack with the user-supplied replacement Egg sheets."""
import json,hashlib
from PIL import Image,ImageDraw
import build_v8_sprites as prior
import build_sprites as base
ROOT=base.ROOT;OUT=base.OUT

def main():
 prior.main()
 pack=json.loads((OUT/'pet.json').read_text());meta=json.loads((ROOT/'art/crops.json').read_text())
 def extract(name,cols,ys):
  source=ROOT/'art/source'/name;im=Image.open(source).convert('RGBA')
  im.putalpha(im.getchannel('A').point(lambda a:0 if a<32 else a))
  bs=[]
  for y1,y2 in ys:
   for col in range(cols):
    x1=round(col*im.width/cols);x2=round((col+1)*im.width/cols)
    b=im.crop((x1,y1,x2,y2)).getbbox()
    assert b,(name,col,y1)
    bs.append((x1+b[0],y1+b[1],x1+b[2],y1+b[3]))
  scale=min(50/(bs[0][2]-bs[0][0]),86/max(max(b[2]-b[0],b[3]-b[1]) for b in bs));frames=[]
  for b in bs:
   crop=im.crop(b);crop=crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.NEAREST)
   f=Image.new('RGBA',(96,96));f.alpha_composite(crop,((96-crop.width)//2,90-crop.height));frames.append(f)
  return frames,bs,scale,hashlib.sha256(source.read_bytes()).hexdigest()
 hatch=extract('EGG_hatching.png',10,[(0,310),(310,550),(550,790),(790,1024)])
 shake=extract('EGG_shaking.png',6,[(0,724)])
 contact=Image.new('RGB',(1200,440),'#1d2832');draw=ImageDraw.Draw(contact)
 for row,(key,name,data,indices,loop,ms) in enumerate([
  ('idle','EGG_hatching.png',hatch,list(range(4)),True,[600]*4),
  ('shake','EGG_shaking.png',shake,list(range(6)),True,[150]*6),
  ('crack','EGG_hatching.png',hatch,list(range(4,16)),False,[120]*12),
  ('hatch','EGG_hatching.png',hatch,list(range(16,40)),False,[140]*23+[500])]):
  frames,bs,scale,sha=data;sheet=Image.new('RGBA',(96*len(indices),96))
  draw.text((8,row*110+4),'egg/'+key,fill='white')
  for i,index in enumerate(indices):
   sheet.paste(frames[index],(96*i,0));thumb=frames[index].resize((48,48),Image.Resampling.NEAREST);contact.paste(thumb,(8+i*49,row*110+32),thumb)
  sheet.save(OUT/('egg/'+key+'.png'))
  pack['animations']['egg/'+key]={'file':'egg/'+key+'.png','frames':len(indices),'rows':1,'frameWidth':96,'frameHeight':96,'anchor':[48,90],'durations':ms,'loop':loop}
  meta['egg/'+key]={'source':name,'sha256':sha,'crops':[bs[i] for i in indices],'scale':scale,'sourceFrameIndices':indices,'alphaNoiseThreshold':32}
 pack['animations']['slime/idle']['durations']=[350]*pack['animations']['slime/idle']['frames']
 pack['version']='1.0.0'
 (OUT/'pet.json').write_text(json.dumps(pack,indent=2)+'\n');(ROOT/'art/crops.json').write_text(json.dumps(meta,indent=2)+'\n');contact.save(ROOT/'docs/egg-contact.png')
if __name__=='__main__':main()
