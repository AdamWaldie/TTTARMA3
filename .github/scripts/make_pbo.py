#!/usr/bin/env python3
"""
Pack a directory into an Arma PBO file: uncompressed, no custom headers.

Minimal, from-scratch implementation of the documented PBO format: a list of
file entries (null-terminated filename, then packing method, original size,
reserved, timestamp, data size - all little-endian uint32), a terminating
all-zero entry, the concatenated raw file data in the same order, and a
trailing checksum (a single 0x00 byte followed by the 20-byte SHA1 digest of
every byte written before it).

The product-entry / custom-header block some PBOs carry at the very start
(mime type "Vers", used to declare an addon's virtual path prefix) is
optional and addon-specific, not needed by missions - skipped entirely, so
there's no ambiguity to get wrong about how that 4-character tag is meant to
be byte-ordered on disk versus the rest of the little-endian format.

Self-verifies after writing: re-parses the file it just produced, confirms
every entry's declared size matches the bytes actually present, confirms
each entry's data matches the source file byte for byte, and recomputes the
trailing SHA1 to confirm it matches. Exits non-zero (rather than shipping a
file nobody's checked) if any of that disagrees.

Usage: make_pbo.py <source_dir> <output.pbo>
"""
import hashlib
import os
import struct
import sys


def iter_files(source_dir):
    """Yield (absolute_path, pbo_relative_path) for every file under
    source_dir, sorted for a deterministic, reproducible pack order."""
    paths = []
    for root, _dirs, files in os.walk(source_dir):
        for name in files:
            abs_path = os.path.join(root, name)
            rel_path = os.path.relpath(abs_path, source_dir)
            paths.append((abs_path, rel_path.replace(os.sep, "\\")))
    paths.sort(key=lambda p: p[1].lower())
    return paths


def write_entry(f, filename: str, packing: int, original_size: int, reserved: int, timestamp: int, data_size: int):
    f.write(filename.encode("utf-8"))
    f.write(b"\x00")
    f.write(struct.pack("<5I", packing, original_size, reserved, timestamp, data_size))


def pack(source_dir, output_path):
    entries = iter_files(source_dir)
    if not entries:
        print(f"error: no files found under {source_dir}", file=sys.stderr)
        sys.exit(1)

    with open(output_path, "wb") as f:
        for abs_path, rel_path in entries:
            size = os.path.getsize(abs_path)
            write_entry(f, rel_path, 0, size, 0, 0, size)

        write_entry(f, "", 0, 0, 0, 0, 0)  # terminating entry

        for abs_path, _rel_path in entries:
            with open(abs_path, "rb") as src:
                f.write(src.read())

        digest_input_size = f.tell()

    with open(output_path, "rb") as f:
        hasher = hashlib.sha1()
        hasher.update(f.read(digest_input_size))
        digest = hasher.digest()

    with open(output_path, "ab") as f:
        f.write(b"\x00")
        f.write(digest)

    return entries


def verify(source_dir, output_path, entries):
    with open(output_path, "rb") as f:
        data = f.read()

    pos = 0
    parsed = []
    while True:
        nul = data.index(b"\x00", pos)
        filename = data[pos:nul].decode("utf-8")
        pos = nul + 1
        packing, original_size, reserved, timestamp, data_size = struct.unpack_from("<5I", data, pos)
        pos += 20
        if filename == "" and data_size == 0:
            break
        parsed.append((filename, data_size))

    if [p[0] for p in parsed] != [e[1] for e in entries]:
        print("verify error: filename list does not match what was packed", file=sys.stderr)
        return False

    for (filename, data_size), (abs_path, _rel_path) in zip(parsed, entries):
        actual = data[pos:pos + data_size]
        pos += data_size
        with open(abs_path, "rb") as src:
            expected = src.read()
        if actual != expected:
            print(f"verify error: {filename} data does not match source file byte for byte", file=sys.stderr)
            return False

    marker = data[pos]
    stored_digest = data[pos + 1:pos + 21]
    if marker != 0:
        print(f"verify error: expected 0x00 marker before checksum, found {marker:#x}", file=sys.stderr)
        return False
    if pos + 21 != len(data):
        print("verify error: trailing bytes after checksum, or checksum truncated", file=sys.stderr)
        return False

    recomputed = hashlib.sha1(data[:pos]).digest()
    if recomputed != stored_digest:
        print("verify error: recomputed SHA1 does not match the stored checksum", file=sys.stderr)
        return False

    return True


def main():
    if len(sys.argv) != 3:
        print("usage: make_pbo.py <source_dir> <output.pbo>", file=sys.stderr)
        sys.exit(2)

    source_dir, output_path = sys.argv[1], sys.argv[2]
    entries = pack(source_dir, output_path)

    if not verify(source_dir, output_path, entries):
        print(f"error: {output_path} failed self-verification, not shipping it", file=sys.stderr)
        sys.exit(1)

    print(f"packed and verified {output_path}: {len(entries)} files, {os.path.getsize(output_path)} bytes")


if __name__ == "__main__":
    main()
