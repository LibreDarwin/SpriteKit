#!/usr/bin/env python3
"""Deterministic corpus generator for the atlasc (TextureAtlas) conformance suite.

For every case the generator:
  1. writes a deterministic sprite set into <case>/<case>.atlas/ (valid PNG
     files produced byte-identically every run -- raw zlib, no ImageIO),
  2. writes the invocation line(s): an "args" file (one NUL-separated argv) or
     a "cmds" file (one argv per line, for multi-invocation cases), and
  3. when --oracle is given, runs Apple's TextureAtlas in a clean workspace and
     records the golden output under <case>/golden/ (exit, stdout, stderr and
     the ws/out tree), which run_tests.py compares our build against.

Output paths in the invocation lines are relative to the workspace and must be
used with cwd = workspace, so both the oracle and the subject print identical
path strings on stdout.

Usage: make_corpus.py [--oracle PATH] [--case NAME[,NAME...]]
"""
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
SUITE = os.path.join(HERE, "TextureAtlas")
DEFAULT_ORACLE = ("/Applications/Xcode.app/Contents/Developer/usr/bin/TextureAtlas")


def png_chunk(tag, data):
    body = struct.pack(">I", len(data)) + tag + data
    return body + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff)


def write_png(path, w, h, pixels):
    """Write a deterministic RGBA8 PNG.  pixels is a bytearray of w*h*4."""
    raw = bytearray()
    for y in range(h):
        raw += b"\x00"
        raw += pixels[y * w * 4:(y + 1) * w * 4]
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(png_chunk(b"IHDR", ihdr))
        f.write(png_chunk(b"IDAT", zlib.compress(bytes(raw), 9)))
        f.write(png_chunk(b"IEND", b""))


def solid(w, h, r, g, b, a=255):
    px = bytearray()
    for _ in range(h):
        px += solid_row(w, r, g, b, a)
    return px, w, h, a


def solid_row(w, r, g, b, a):
    row = bytearray()
    for _ in range(w):
        row += bytes((r, g, b, a))
    return row


def vgrad(w, h, top, bottom, a=255):
    """Vertical gradient between two RGB colors, full alpha."""
    px = bytearray()
    for y in range(h):
        t = y / max(1, h - 1)
        r = int(top[0] + (bottom[0] - top[0]) * t)
        g = int(top[1] + (bottom[1] - top[1]) * t)
        b = int(top[2] + (bottom[2] - top[2]) * t)
        px += solid_row(w, r, g, b, a)
    return px


def border(src, margin, rgb=None):
    """Zero the outermost <margin> pixels (trims the sprite on packing)."""
    w, h, a = src[1], src[2], src[3]
    px = bytearray(src[0])
    for y in range(h):
        if y < margin or y >= h - margin:
            for x in range(w):
                i = (y * w + x) * 4
                px[i:i + 4] = b"\x00\x00\x00\x00" if rgb is None else bytes(rgb) + b"\x00"
        else:
            for x in range(margin):
                i = (y * w + x) * 4
                px[i:i + 4] = b"\x00\x00\x00\x00" if rgb is None else bytes(rgb) + b"\x00"
            for x in range(w - margin, w):
                i = (y * w + x) * 4
                px[i:i + 4] = b"\x00\x00\x00\x00" if rgb is None else bytes(rgb) + b"\x00"
    return px, w, h, a


def edge_alpha(px, w, h):
    """Fade alpha from core (255) to 1 at a one-pixel soft rim."""
    for y in range(h):
        for x in range(w):
            i = (y * w + x) * 4
            rim = min(x, y, w - 1 - x, h - 1 - y)
            if rim == 0:
                px[i + 3] = 1
    return px


def small_sprite_set(d):
    """The five sprites behind every small-case fixture."""
    os.makedirs(d, exist_ok=True)
    # icon: 24x24, 4px transparent ring around an opaque 16x16 core (trims).
    icon, _, _, _ = border(solid(24, 24, 0, 120, 255), 4)
    write_png(os.path.join(d, "icon.png"), 24, 24, icon)
    # hero: 64x64 opaque gradient (untrimmed, gets the extruded skirt).
    hero = vgrad(64, 64, (255, 64, 0), (255, 220, 64))
    write_png(os.path.join(d, "hero.png"), 64, 64, hero)
    # hero@2x: 128x128 opaque gradient (lands on its own @2x page).
    huge = vgrad(128, 128, (0, 128, 255), (64, 255, 220))
    write_png(os.path.join(d, "hero@2x.png"), 128, 128, huge)
    # spark: 40x40, 4px transparent ring, core with a 1px alpha-graded rim.
    spark, sw, sh, _ = border(solid(40, 40, 255, 255, 255, a=255), 4)
    spark = edge_alpha(bytearray(spark), sw, sh)
    write_png(os.path.join(d, "spark.png"), sw, sh, spark)
    # bg: 256x128 opaque gradient (untrimmed, extruded).
    bg = vgrad(256, 128, (40, 40, 40), (220, 220, 220))
    write_png(os.path.join(d, "bg.png"), 256, 128, bg)


def write_case(name, cmds_lines, build_src):
    case_dir = os.path.join(SUITE, name)
    src_dir = os.path.join(case_dir, name + ".atlas")
    shutil.rmtree(case_dir, ignore_errors=True)
    os.makedirs(case_dir, exist_ok=True)
    if build_src:
        build_src(src_dir)
    if len(cmds_lines) > 1:
        with open(os.path.join(case_dir, "cmds"), "w") as f:
            for argv in cmds_lines:
                f.write(" ".join(argv) + "\n")
    else:
        with open(os.path.join(case_dir, "args"), "w") as f:
            f.write("\0".join(cmds_lines[0]))
    return case_dir


def ws_path():
    return os.path.join(tempfile.gettempdir(), "atlas-conform-ws")


def record_golden(case_dir, oracle):
    """Run the oracle in a clean workspace and store the golden output.

    The workspace path is fixed (see ws_path) so verbose stdout, which embeds
    absolute file:// URLs, is byte-identical between recording and the subject
    runs in run_tests.py.
    """
    ws = ws_path()
    shutil.rmtree(ws, ignore_errors=True)
    try:
        os.makedirs(ws)
        for entry in os.listdir(case_dir):
            if entry in ("args", "cmds", "golden"):
                continue
            shutil.copytree(os.path.join(case_dir, entry),
                            os.path.join(ws, entry))
        # The output folder already exists when Xcode drives the tool.
        os.makedirs(os.path.join(ws, "out"), exist_ok=True)

        def split_cmds():
            cmds_path = os.path.join(case_dir, "cmds")
            args_path = os.path.join(case_dir, "args")
            if os.path.exists(cmds_path):
                return [line.split() for line in
                        open(cmds_path).read().splitlines() if line.strip()]
            if os.path.exists(args_path):
                return [[a.decode("utf-8") for a in
                         open(args_path, "rb").read().split(b"\0") if a != b""]]
            return []

        results = []
        for argv in split_cmds():
            p = subprocess.run([oracle] + argv, cwd=ws,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            results.append((p.returncode & 0xff, p.stdout, p.stderr))

        golden = os.path.join(case_dir, "golden")
        shutil.rmtree(golden, ignore_errors=True)
        os.makedirs(golden)
        with open(os.path.join(golden, "exit"), "w") as f:
            f.write("\n".join(str(r[0]) for r in results))
        with open(os.path.join(golden, "stdout"), "wb") as f:
            f.write(b"\n".join(r[1] for r in results))
        with open(os.path.join(golden, "stderr"), "wb") as f:
            f.write(b"\n".join(r[2] for r in results))
        out_root = os.path.join(golden, "tree")
        os.makedirs(out_root, exist_ok=True)
        out_src = os.path.join(ws, "out")
        if os.path.isdir(out_src):
            for root, dirs, files in os.walk(out_src):
                for f in files:
                    rel = os.path.relpath(os.path.join(root, f), out_src)
                    dst = os.path.join(out_root, rel)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    shutil.copy2(os.path.join(root, f), dst)
    finally:
        shutil.rmtree(ws, ignore_errors=True)
    print("golden: %s" % case_dir)


def small_cases():
    def argv(name, extra):
        return extra + ["%s.atlas" % name, "out"]
    return [
        ("mixed", argv("mixed", [])),
        ("mixed-pot", argv("mixed-pot", ["-p"])),
        ("mixed-size2", argv("mixed-size2", ["-s", "2"])),
        ("mixed-verbose", argv("mixed-verbose", ["-v"])),
        ("mixed-quiet", argv("mixed-quiet", ["-g"])),
    ]


def format_cases():
    return [("format-pvr8888", "2"), ("format-pvr4444", "3"),
            ("format-pvr5551", "4"), ("format-pvr565", "5")]


def build_small(src_dir):
    small_sprite_set(src_dir)


def build_multipage(src_dir):
    os.makedirs(src_dir, exist_ok=True)
    for i in range(10):
        px, w, h, _ = solid(600, 600, (i * 20) % 256, 80, 200 - (i * 10))
        write_png(os.path.join(src_dir, "tile%d.png" % i), w, h, px)


def build_split(src_dir):
    os.makedirs(src_dir, exist_ok=True)
    px = vgrad(3000, 100, (10, 10, 10), (200, 200, 200))
    write_png(os.path.join(src_dir, "wide.png"), 3000, 100, px)
    icon, _, _, _ = border(solid(24, 24, 40, 160, 90), 4)
    write_png(os.path.join(src_dir, "icon.png"), 24, 24, icon)


def build_suffixes(src_dir):
    os.makedirs(src_dir, exist_ok=True)
    names = ["logo@3x.png", "title@2x~ipad.png", "btn~iphone.png",
             "plate-568h@2x.png", "hero@1080.png", "photo.jpg"]
    for i, n in enumerate(names):
        w, h = 32, 32
        px, _, _, _ = solid(w, h, (i * 30) % 256, 120, 60, a=255)
        write_png(os.path.join(src_dir, n), w, h, px)


def build_junk(src_dir):
    small_sprite_set(src_dir)
    with open(os.path.join(src_dir, "readme.txt"), "w") as f:
        f.write("not an image\n")


def build_empty(src_dir):
    pass


def main():
    args = sys.argv[1:]
    oracle = DEFAULT_ORACLE
    case_filter = None
    i = 0
    while i < len(args):
        if args[i] == "--oracle" and i + 1 < len(args):
            oracle = args[i + 1]
            i += 2
        elif args[i] == "--case" and i + 1 < len(args):
            case_filter = args[i + 1].split(",")
            i += 2
        else:
            sys.exit("usage: make_corpus.py [--oracle PATH] [--case NAME,...]")

    plan = []
    for name, argv in small_cases():
        plan.append((name, argv, build_small))
    for name, fmt in format_cases():
        plan.append((name, ["-f", fmt, "%s.atlas" % name, "out"], build_small))
    plan += [
        ("copy", ["-c", "./copy.atlas", "out"], build_small),
        ("incremental", None, build_small),
        ("multipage", ["multipage.atlas", "out"], build_multipage),
        ("split", ["split.atlas", "out"], build_split),
        ("suffixes", ["suffixes.atlas", "out"], build_suffixes),
        ("junk", ["junk.atlas", "out"], build_junk),
        ("empty", ["empty.atlas", "out"], build_empty),
    ]

    for name, argv, build_src in plan:
        if case_filter and name not in case_filter:
            continue
        # The incremental case runs the same invocation twice via a cmds file.
        if name == "incremental":
            cmds_lines = [["incremental.atlas", "out"],
                          ["incremental.atlas", "out"]]
        else:
            cmds_lines = [argv]
        case_dir = write_case(name, cmds_lines, build_src)
        if os.path.exists(oracle):
            record_golden(case_dir, oracle)
        else:
            print("warning: oracle %r not found; golden not recorded for %s"
                  % (oracle, name))


if __name__ == "__main__":
    main()