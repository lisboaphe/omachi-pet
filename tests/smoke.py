#!/usr/bin/env python3
"""Real Quickshell controller, room, activities, bar, migrations and travel state tests."""
import json,os,shutil,subprocess,tempfile,time
from pathlib import Path
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='omachi-v8-smoke-') as tmp:
 work=Path(tmp);app=work/'app';shutil.copytree(root,app,ignore=shutil.ignore_patterns('__pycache__'))
 shutil.copyfile(app/'tests/smoke.qml',app/'smoke.qml')
 for folder in ['runtime','state','cache']:(work/folder).mkdir(mode=0o700)
 env=dict(os.environ,QT_QPA_PLATFORM='offscreen',QT_QPA_PLATFORMTHEME='generic',QT_QUICK_CONTROLS_STYLE='Basic',QT_QUICK_BACKEND='software',XDG_RUNTIME_DIR=str(work/'runtime'),XDG_STATE_HOME=str(work/'state'),XDG_CACHE_HOME=str(work/'cache'),OMACHI_TEST_OUTPUT=str(work))
 env.pop('WAYLAND_DISPLAY',None);env.pop('HYPRLAND_INSTANCE_SIGNATURE',None)
 save=work/'state/omachi-pet/pet-v7.json';legacy=save.with_name('pet-v5.json')
 for scenario,expect in [('fresh','SMOKE LOADED STAGE 0'),('restore','SMOKE LOADED STAGE 1'),('migrate','PASS MIGRATED'),('portal','PASS PORTAL ARRIVED HOME'),('fatigue','PASS AUTO WAKE'),('recovery','PASS RECOVERY ARRIVED'),('corrupt','PASS CORRUPT PRESERVED'),('future','PASS CORRUPT PRESERVED')]:
  if scenario=='migrate':
   save.unlink();legacy.write_text(json.dumps({'schemaVersion':5,'name':'Luna','stage':1,'xp':77,'growth':{'mind':40,'power':9,'creativity':12,'calm':8},'lastSaved':time.time()*1000}));legacy_before=legacy.read_bytes()
  if scenario=='corrupt':save.write_text('{broken save')
  if scenario=='future':save.write_text('{"schemaVersion":99}')
  original=save.read_bytes() if save.exists() else None
  result=subprocess.run(['quickshell','-p',str(app/'smoke.qml')],env=dict(env,OMACHI_TEST_SCENARIO=scenario),capture_output=True,text=True,timeout=12)
  log=result.stdout+result.stderr
  assert result.returncode==0 and expect in log and 'SMOKE FAILED' not in log,log
  for error in ['ReferenceError','TypeError','Failed to load configuration','Unable to assign','Binding loop']:
   assert error not in log,log
  if scenario in ['corrupt','future']:assert save.read_bytes()==original
  else:
   data=json.loads(save.read_text());assert data['stage']==1 and data['schemaVersion']==7 and data['nameConfirmed'] is True
   assert 'SMOKE STATUS Saved locally' in log,log
   if scenario not in ['portal','recovery']:assert data['activityMappings']['music']=='mind' and data['appCategories']['test-custom-app']=='gaming'
   assert (work/'home.png').stat().st_size>1000
   if scenario=='migrate':assert legacy.read_bytes()==legacy_before
   if scenario=='fresh' and os.environ.get('OMACHI_PREVIEW_DIR'):
    out=Path(os.environ['OMACHI_PREVIEW_DIR']);out.mkdir(parents=True,exist_ok=True)
    for name in ['home','attributes','activities','bar','naming','low-mood']:shutil.copyfile(work/(name+'.png'),out/(name+'-preview.png'))
  print('PASS Quickshell '+scenario)
