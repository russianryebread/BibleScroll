from collections import Counter
from pathlib import Path

source = Path(__file__).resolve().parents[1] / "BibleScroll/Resources/kjv.txt"
rows = source.read_text(encoding="utf-8").splitlines()
refs = []
for line in rows:
    book, address, text = line.split(" ", 2)
    assert text.strip(), (book, address)
    chapter, verse = map(int, address.split(":"))
    refs.append((book, chapter, verse))

assert len(refs) == 31_102, len(refs)
assert len({book for book, _, _ in refs}) == 66
assert not [ref for ref, count in Counter(refs).items() if count > 1]
assert ("PSA", 23, 1) in refs and ("REV", 22, 21) in refs
print("KJV validated: 66 books, 31,102 unique nonempty verses")
