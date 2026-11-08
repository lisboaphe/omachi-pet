#!/usr/bin/env python3
"""Create a deterministic, source-inclusive release ZIP without caches or saves."""
import hashlib,json,subprocess,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
version=json.loads((ROOT/'manifest.json').read_text())['version']
output=ROOT.parent/('omachi-pet-v'+version+'.zip')
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
 # Only tracked files ship, so stray local files (saves, notes, builds) never leak into a release.
 tracked=subprocess.run(['git','-C',str(ROOT),'ls-files','-z'],check=True,capture_output=True).stdout.decode().split('\0')
 for rel in sorted(Path(n) for n in tracked if n):
  path=ROOT/rel
  if not path.is_file() or path.is_symlink() or path.suffix in ('.pyc','.zip'):continue
  info=zipfile.ZipInfo('omachi-pet/'+rel.as_posix(),date_time=(2026,9,25,0,0,0))
  info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o100644<<16
  archive.writestr(info,path.read_bytes())
with zipfile.ZipFile(output) as archive:
 assert archive.testzip() is None
 names=archive.namelist();assert len(names)==len(set(names));assert all(n.startswith('omachi-pet/') and '..' not in Path(n).parts for n in names)
checksum=hashlib.sha256(output.read_bytes()).hexdigest()
output.with_suffix('.zip.sha256').write_text(checksum+'  '+output.name+'\n')
print(f'{output.name}: {len(names)} files, {output.stat().st_size:,} bytes, ZIP integrity passed')
print('SHA256 '+checksum)
