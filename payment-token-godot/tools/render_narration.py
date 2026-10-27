"""Regenerate bundled speech on a Mac with the requested installed system voice."""
import argparse, hashlib, json, subprocess, tempfile, wave
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
parser=argparse.ArgumentParser()
parser.add_argument('--voice',default='Samantha (English (US))')
parser.add_argument('--rate',type=int,default=155)
args=parser.parse_args()
root=Path(__file__).resolve().parent.parent
lessons=json.loads((root/'assets/lessons.json').read_text())
output=root/'assets/narration';output.mkdir(exist_ok=True)
def render(item):
    i,j,text=item
    name=f'lesson-{i:02d}-{j}.wav'
    with tempfile.TemporaryDirectory() as tmp:
        aiff=Path(tmp)/'voice.aiff'
        subprocess.run(['/usr/bin/say','-v',args.voice,'-r',str(args.rate),'-o',str(aiff),text],check=True)
        subprocess.run(['/usr/bin/afconvert','-f','WAVE','-d','LEI16@22050','-c','1',str(aiff),str(output/name)],check=True)
    with wave.open(str(output/name)) as w:
        seconds=w.getnframes()/w.getframerate()
        if seconds<=0:raise RuntimeError(f'No speech generated for {name}; check system speech access.')
    return {'file':name,'caption_sha256':hashlib.sha256(text.encode()).hexdigest(),'duration_seconds':round(seconds,3)}
items=[(i,j,text) for i,lesson in enumerate(lessons) for j,text in enumerate(lesson['parts'])]
with ThreadPoolExecutor(max_workers=2) as pool:clips=list(pool.map(render,items))
(output/'manifest.json').write_text(json.dumps({'voice':args.voice,'words_per_minute':args.rate,'clips':clips},indent=2)+'\n')
print(f'Rendered {len(clips)} clips; {sum(c["duration_seconds"] for c in clips)/60:.1f} minutes.')
