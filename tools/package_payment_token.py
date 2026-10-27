"""Build a portable Godot source archive, without caches or source textbook material."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
root = Path(__file__).resolve().parent.parent
project = root / 'payment-token-godot'
output = root / 'site/downloads/Payment-Token-Lab-Godot.zip'
files = [p for p in project.rglob('*') if p.is_file() and '.godot' not in p.parts and p.name != '.DS_Store']
with ZipFile(output, 'w', ZIP_DEFLATED, compresslevel=9) as z:
    for p in sorted(files):
        z.write(p, 'Payment-Token-Lab-Godot/' + p.relative_to(project).as_posix())
with ZipFile(output) as z:
    assert z.testzip() is None
    assert 'Payment-Token-Lab-Godot/project.godot' in z.namelist()
    assert not any('/.godot/' in n or n.endswith(('.pdf','.pptx')) for n in z.namelist())
print(f'{output.name}: {len(files)} files, {output.stat().st_size:,} bytes')
