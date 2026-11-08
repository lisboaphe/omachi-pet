import json,os,subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class Installer(unittest.TestCase):
 def test_update_backup_and_failed_update_rollback(self):
  with tempfile.TemporaryDirectory(prefix='omachi-install-test-') as tmp:
   work=Path(tmp);bins=work/'bin';bins.mkdir()
   (bins/'omarchy').write_text('#!/bin/sh\nprintf "%s\n" "$*" >> "$INSTALL_LOG"\nif [ "$1 $2" = "plugin enable" ]; then\n if [ "${FAIL_ENABLE:-0}" = 1 ]; then exit 1; fi\n count=0\n [ ! -f "$INSTALL_LOG.attempt" ] || count=$(cat "$INSTALL_LOG.attempt")\n count=$((count + 1)); echo "$count" > "$INSTALL_LOG.attempt"\n if [ "$count" -lt 4 ]; then\n  echo "omarchy-plugin-enable: plugin \'community.omachi-pet\' is not known; run: omarchy-shell shell rescanPlugins" >&2\n  exit 1\n fi\nfi\nexit 0\n')
   (bins/'omarchy-shell').write_text('#!/bin/sh\nexit 0\n')
   for p in bins.iterdir():p.chmod(0o755)
   env=dict(os.environ,PATH=str(bins)+os.pathsep+os.environ['PATH'],XDG_CONFIG_HOME=str(work/'config'),XDG_DATA_HOME=str(work/'data'),INSTALL_LOG=str(work/'commands.log'))
   dest=work/'config/omarchy/plugins/community.omachi-pet'
   def install(fail=False,args=()):return subprocess.run(['bash',str(ROOT/'install.sh'),*args],env=dict(env,FAIL_ENABLE='1' if fail else '0'),capture_output=True,text=True,timeout=15)
   result=install();self.assertEqual(result.returncode,0,result.stdout+result.stderr)
   self.assertIn('is not installed. Installing',result.stdout)
   self.assertNotIn('plugin disable', (work/'commands.log').read_text())
   self.assertEqual(list((work/'data/omachi-pet/plugin-backups').iterdir()),[])
   self.assertEqual(json.loads((dest/'manifest.json').read_text())['version'],'1.0.0')
   commands=(work/'commands.log').read_text().splitlines();self.assertEqual(commands[-1],'restart shell');self.assertEqual(commands.count('plugin enable community.omachi-pet --section right'),4)
   (dest/'previous-install.txt').write_text('user-owned marker')
   result=install();self.assertEqual(result.returncode,0,result.stdout+result.stderr)
   self.assertIn('Existing Omachi Pet found. Updating',result.stdout)
   self.assertIn('plugin disable community.omachi-pet',(work/'commands.log').read_text())
   backups=list((work/'data/omachi-pet/plugin-backups').glob('upgrade-from-v1.0.0-*'))
   self.assertEqual(len(backups),1);self.assertEqual((backups[0]/'previous-install.txt').read_text(),'user-owned marker');self.assertFalse((dest/'previous-install.txt').exists());self.assertFalse((dest/'art').exists());self.assertFalse((dest/'tests').exists());self.assertTrue((dest/'src/Service.qml').is_file())
   (dest/'rollback-marker.txt').write_text('restore me')
   result=install(True);self.assertNotEqual(result.returncode,0)
   self.assertEqual((dest/'rollback-marker.txt').read_text(),'restore me')
   self.assertEqual(list((work/'config/omarchy').glob('.omachi-install.*')),[])

   for section,expected in [('left','left'),('middle','center'),('right','right')]:
    result=install(args=('--section',section));self.assertEqual(result.returncode,0,result.stdout+result.stderr)
    commands=(work/'commands.log').read_text().splitlines()
    self.assertEqual(commands[-2],'plugin enable community.omachi-pet --section '+expected)
   before=(work/'commands.log').read_text()
   result=install(args=('--section','invalid'));self.assertNotEqual(result.returncode,0)
   self.assertEqual((work/'commands.log').read_text(),before)
