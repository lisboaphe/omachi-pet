import json,struct,unittest,zlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class Assets(unittest.TestCase):
 def test_manifest_and_entrypoints(self):
  manifest=json.loads((ROOT/'manifest.json').read_text());self.assertEqual(manifest['version'],'1.0.0')
  for p in manifest['entryPoints'].values():self.assertTrue((ROOT/p).is_file())
 def test_rgba_png_dimensions_and_checksums(self):
  pack=json.loads((ROOT/'assets/pets/slime-default/pet.json').read_text())
  for key,a in pack['animations'].items():
   with self.subTest(animation=key):
    data=(ROOT/'assets/pets/slime-default'/a['file']).read_bytes();self.assertEqual(data[:8],b'\x89PNG\r\n\x1a\n')
    width,height,depth,colour=struct.unpack('>IIBB',data[16:26]);self.assertEqual((width,height),(96*a['frames'],96*a['rows']));self.assertEqual(colour,6)
    i=8
    while i<len(data):
     n=struct.unpack('>I',data[i:i+4])[0];chunk=data[i+4:i+8+n];checksum=struct.unpack('>I',data[i+8+n:i+12+n])[0];self.assertEqual(zlib.crc32(chunk),checksum);i+=n+12
 def test_source_crop_provenance(self):
  import hashlib
  meta=json.loads((ROOT/'art/crops.json').read_text())
  for a in meta.values():
   if 'source' in a:self.assertEqual(hashlib.sha256((ROOT/'art/source'/a['source']).read_bytes()).hexdigest(),a['sha256'])
if __name__=='__main__':unittest.main()
