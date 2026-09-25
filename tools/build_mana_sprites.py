#!/usr/bin/env python3
"""Rebuild pack and import the two supplied mana Egg loops."""
import hashlib,json
from PIL import Image,ImageDraw
import build_egg_sprites as prior
import build_sprites as base
ROOT=base.ROOT;OUT=base.OUT

def main():
 prior.main();pack=json.loads((OUT/'pet.json').read_text());meta=json.loads((ROOT/'art/crops.json').read_text())
 contact=Image.new('RGB',(1200,240),'#24313b');draw=ImageDraw.Draw(contact)
 for row,(key,file,rows,reference,ms) in enumerate([
  ('mana','EGG_Mana.png',[(0,280),(280,562),(562,840),(840,1122)],164,130),
  ('shake_mana','EGG_shaking_mana.png',[(0,512),(512,1024)],182,180)]):
  p=ROOT/'art/source'/file;im=Image.open(p).convert('RGBA');im.putalpha(im.getchannel('A').point(lambda a:0 if a<32 else a));bs=[]
  for y1,y2 in rows:
   for c in range(5):
    x1=round(c*im.width/5);x2=round((c+1)*im.width/5);b=im.crop((x1,y1,x2,y2)).getbbox();assert b
    bs.append((x1+b[0],y1+b[1],x1+b[2],y1+b[3]))
  scale=min(50/reference,86/max(max(b[2]-b[0],b[3]-b[1]) for b in bs))
  sheet=Image.new('RGBA',(96*len(bs),96));draw.text((8,row*120+4),'egg/'+key,fill='white')
  for i,b in enumerate(bs):
   crop=im.crop(b);crop=crop.resize((max(1,round(crop.width*scale)),max(1,round(crop.height*scale))),Image.Resampling.NEAREST)
   f=Image.new('RGBA',(96,96));f.alpha_composite(crop,((96-crop.width)//2,90-crop.height));sheet.paste(f,(i*96,0));thumb=f.resize((54,54),Image.Resampling.NEAREST);contact.paste(thumb,(8+i*57,row*120+30),thumb)
  sheet.save(OUT/('egg/'+key+'.png'))
  pack['animations']['egg/'+key]={'file':'egg/'+key+'.png','frames':len(bs),'rows':1,'frameWidth':96,'frameHeight':96,'anchor':[48,90],'durations':[ms]*len(bs),'loop':True}
  meta['egg/'+key]={'source':file,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'crops':bs,'scale':scale,'alphaNoiseThreshold':32}
 # Latest roaming and happy sheets, with a shared scale per sheet.
 slime_contact=Image.new('RGB',(1100,240),'#24313b');d=ImageDraw.Draw(slime_contact)
 for row,(key,file,cols,loop,ms) in enumerate([('roam','Slime_Action_Roaming.png',5,True,150),('happy','Slime_Happy.png',10,False,160)]):
  p=ROOT/'art/source'/file;im=Image.open(p).convert('RGBA');im.putalpha(im.getchannel('A').point(lambda a:0 if a<32 else a));bs=[]
  for c in range(cols):
   x1=round(c*im.width/cols);x2=round((c+1)*im.width/cols);b=im.crop((x1,0,x2,im.height)).getbbox();assert b;bs.append((x1+b[0],b[1],x1+b[2],b[3]))
  scale=min(50/(bs[0][2]-bs[0][0]),86/max(max(b[2]-b[0],b[3]-b[1]) for b in bs));sheet=Image.new('RGBA',(96*cols,96));d.text((8,row*120+4),'slime/'+key,fill='white')
  for i,b in enumerate(bs):
   crop=im.crop(b);crop=crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.NEAREST);f=Image.new('RGBA',(96,96));f.alpha_composite(crop,((96-crop.width)//2,90-crop.height));sheet.paste(f,(i*96,0));slime_contact.paste(f,(8+i*100,row*120+20),f)
  sheet.save(OUT/('slime/'+key+'.png'));pack['animations']['slime/'+key]={'file':'slime/'+key+'.png','frames':cols,'rows':1,'frameWidth':96,'frameHeight':96,'anchor':[48,90],'durations':[ms]*cols,'loop':loop};pack['fallbacks'].pop('slime/'+key,None)
  meta['slime/'+key]={'source':file,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'crops':bs,'scale':scale,'alphaNoiseThreshold':32}
 slime_contact.save(ROOT/'docs/new-slime-contact.png')
 pack['version']='1.0.0';(OUT/'pet.json').write_text(json.dumps(pack,indent=2)+'\n');(ROOT/'art/crops.json').write_text(json.dumps(meta,indent=2)+'\n');contact.save(ROOT/'docs/mana-contact.png')
if __name__=='__main__':main()
