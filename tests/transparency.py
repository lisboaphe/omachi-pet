"""Render a simulated desktop and check QML compositing over black and white. Requires Pillow."""
import os,shutil,subprocess,tempfile
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='omachi-alpha-') as t:
 work=Path(t);app=work/'app';shutil.copytree(root,app,ignore=shutil.ignore_patterns('__pycache__'))
 shutil.copyfile(app/'tests/transparency.qml',app/'transparency.qml')
 for folder in ['runtime','state','cache']:(work/folder).mkdir(mode=0o700)
 env=dict(os.environ,QT_QPA_PLATFORM='offscreen',QT_QPA_PLATFORMTHEME='generic',QT_QUICK_CONTROLS_STYLE='Basic',QT_QUICK_BACKEND='software',XDG_RUNTIME_DIR=str(work/'runtime'),XDG_STATE_HOME=str(work/'state'),XDG_CACHE_HOME=str(work/'cache'),OMACHI_TEST_OUTPUT=str(work))
 env.pop('WAYLAND_DISPLAY',None);env.pop('HYPRLAND_INSTANCE_SIGNATURE',None)
 result=subprocess.run(['quickshell','-p',str(app/'transparency.qml')],env=env,capture_output=True,text=True,timeout=12)
 log=result.stdout+result.stderr
 assert result.returncode==0 and not any(e in log for e in ['Failed to load configuration','ReferenceError','TypeError','Unable to assign']),log
 shutil.copyfile(work/'transparency-preview.png',root/'docs/transparency-preview.png')
 black=Image.open(work/'black.png').convert('RGB');white=Image.open(work/'white.png').convert('RGB')
 for point in [(100,100),(100,500),(300,615)]:
  delta=white.getpixel(point)[0]-black.getpixel(point)[0]
  assert 96<=delta<=108,(point,delta)
 assert white.getpixel((110,150))==black.getpixel((110,150)),'Landscape should stay opaque'
 print('PASS QML compositing: approximately 40% desktop shows through; landscape remains opaque')
