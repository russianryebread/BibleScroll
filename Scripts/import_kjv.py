"""Convert eBible's eng-kjv2006_usfm.zip to a heading-free verse file."""

import argparse
import re
from pathlib import Path
from zipfile import ZipFile


def clean_verse(source: str) -> str:
    source = re.sub(r"\\f\b.*?\\f\*", "", source)
    source = re.sub(r"\\x\b.*?\\x\*", "", source)
    source = re.sub(r'\\\+?w\s+([^|]+)\|[^\\]*\\\+?w\*', r"\1", source)
    source = re.sub(r"\\(?:\+?[A-Za-z][A-Za-z0-9]*\*?)", "", source)
    source = source.replace("~", " ")
    return re.sub(r"\s+", " ", source).strip()


def convert(archive: Path, destination: Path) -> None:
    lines = []
    with ZipFile(archive) as source:
        for name in sorted(item for item in source.namelist() if item.endswith(".usfm")):
            book = re.search(r"-([1-3A-Z]{3})eng-kjv2006\.usfm$", name)
            if not book:
                raise ValueError(f"Unexpected filename: {name}")
            chapter = None
            for line in source.read(name).decode("utf-8-sig").splitlines():
                if line.startswith("\\c "):
                    chapter = int(line.split()[1])
                elif line.startswith("\\v "):
                    if chapter is None:
                        raise ValueError(f"Verse before chapter in {name}")
                    _, verse, content = line.split(" ", 2)
                    text = clean_verse(content)
                    if not text:
                        raise ValueError(f"Empty verse: {name} {chapter}:{verse}")
                    lines.append(f"{book.group(1)} {chapter}:{verse} {text}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {len(lines):,} verses to {destination}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    convert(args.archive, args.destination)
