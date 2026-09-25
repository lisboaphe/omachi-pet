#!/usr/bin/env python3
"""Create a deterministic, source-inclusive release ZIP without caches or saves."""
import hashlib,json,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
version=json.loads((ROOT/'manifest.json').read_text())['version']
output=ROOT.parent/('omachi-pet-v'+version+'.zip')
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
 for path in sorted(ROOT.rglob('*')):
  rel=path.relative_to(ROOT)
  if not path.is_file() or path.is_symlink() or any(p in ('.git','__pycache__') for p in rel.parts) or path.suffix in ('.pyc','.zip'):continue
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
