"""Build a portable source ZIP without caches, saves, binaries or supplied source documents."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parent.parent
output = root / "site/downloads/Nova-Global-Launch-Godot.zip"
output.parent.mkdir(parents=True, exist_ok=True)
files = [root / name for name in (
    "project.godot", "main.tscn", "export_presets.cfg", "README.md",
    "teaching-guide.md", "START-HERE.txt", ".gitignore",
)]
for folder in ("assets", "scripts", "tests", "tools"):
    files.extend(p for p in (root / folder).rglob("*") if p.is_file() and "__pycache__" not in p.parts)
with ZipFile(output, "w", ZIP_DEFLATED, compresslevel=9) as archive:
    for path in sorted(files):
        archive.write(path, "Nova-Global-Launch/" + path.relative_to(root).as_posix())
with ZipFile(output) as archive:
    assert archive.testzip() is None
    assert "Nova-Global-Launch/project.godot" in archive.namelist()
    assert "Nova-Global-Launch/assets/world-land.geojson" in archive.namelist()
    assert not any("/.godot/" in n or n.endswith(("bus.pdf", ".pptx")) for n in archive.namelist())
print(f"Created {output.name}: {output.stat().st_size:,} bytes, {len(files)} files")
