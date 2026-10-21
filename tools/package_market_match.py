"""Package the standalone Godot project, excluding caches and supplied textbooks."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import shutil
root = Path(__file__).resolve().parent.parent
project = root / 'market-match-godot'
output = root / 'site/downloads/Market-Match-Godot.zip'
files = [p for p in project.rglob('*') if p.is_file() and '.godot' not in p.parts and p.name != '.DS_Store']
with ZipFile(output, 'w', ZIP_DEFLATED, compresslevel=9) as archive:
    for p in sorted(files):
        archive.write(p, 'Market-Match-Godot/' + p.relative_to(project).as_posix())
with ZipFile(output) as archive:
    assert archive.testzip() is None
    assert 'Market-Match-Godot/project.godot' in archive.namelist()
    assert not any('/.godot/' in n or n.endswith(('.pdf','.pptx')) for n in archive.namelist())
# Keep the previously shared download URL useful.
shutil.copyfile(output, root / 'site/downloads/Market-Match.zip')
print(f'{output.name}: {len(files)} files, {output.stat().st_size:,} bytes')
