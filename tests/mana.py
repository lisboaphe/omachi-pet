import json,os,shutil,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='omachi-mana-') as t:
 w=Path(t);app=w/'app';shutil.copytree(root,app,ignore=shutil.ignore_patterns('__pycache__'));shutil.copyfile(app/'tests/mana.qml',app/'mana.qml')
 for folder in ['runtime','state','cache']:(w/folder).mkdir(mode=0o700)
 env=dict(os.environ,QT_QPA_PLATFORM='offscreen',QT_QPA_PLATFORMTHEME='generic',QT_QUICK_CONTROLS_STYLE='Basic',QT_QUICK_BACKEND='software',XDG_RUNTIME_DIR=str(w/'runtime'),XDG_STATE_HOME=str(w/'state'),XDG_CACHE_HOME=str(w/'cache'),OMACHI_TEST_OUTPUT=str(w))
 env.pop('WAYLAND_DISPLAY',None);env.pop('HYPRLAND_INSTANCE_SIGNATURE',None)
 result=subprocess.run(['quickshell','-p',str(app/'mana.qml')],env=env,capture_output=True,text=True,timeout=16);log=result.stdout+result.stderr
 assert result.returncode==0 and 'PASS FULL REVEAL BECOMES SLIME' in log,log
 assert not any(s in log for s in ['MANA FAILED','ReferenceError','TypeError','Unable to assign','Failed to load']),log
 data=json.loads((w/'state/omachi-pet/pet-v7.json').read_text());assert data['manaCharged'] and data['stage']==1
 for file in ['egg-mana-preview.png','egg-final-minute-preview.png']:shutil.copyfile(w/file,root/'docs'/file)
 print('PASS real QML Egg hover, close/leave gating, 10x speed, final-minute cap, mana animation, full reveal and persistence')
