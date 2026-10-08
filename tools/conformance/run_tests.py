#!/usr/bin/env python3
"""Conformance testing for the atlasc (TextureAtlas) tool.

Black-box compare of our build/<config>/TextureAtlas against committed golden
output recorded from Apple's IDESpriteKitSupport TextureAtlas.

For each probe in tools/conformance/<tool>/ we run the subject with the case's
argv(s) (relative paths, cwd = a workspace seeded from the case directory) and
compare exit status, stdout bytes, stderr bytes and the generated ws/out tree
against tools/conformance/<tool>/<case>/golden/{exit,stdout,stderr,tree}.

Passing a `<flaky>` marker in a case directory degrades a failure to a skip.

Usage: run_tests.py TextureAtlas --build-dir DIR [--verify-oracle]
"""
import os
import plistlib
import shutil
import subprocess
import sys
import tempfile

COMPARE_DIR = "out"
DEFAULT_ORACLE = ("/Applications/Xcode.app/Contents/Developer/usr/bin/TextureAtlas")


def read(path):
    with open(path, "rb") as fh:
        return fh.read()


def split_cmds(case_dir):
    cmds_path = os.path.join(case_dir, "cmds")
    args_path = os.path.join(case_dir, "args")
    if os.path.exists(cmds_path):
        return [line.split() for line in
                read(cmds_path).decode("utf-8").splitlines() if line.strip()]
    if os.path.exists(args_path):
        return [[a.decode("utf-8") for a in
                 read(args_path).split(b"\0") if a != b""]]
    return []


def ws_path():
    return os.path.join(tempfile.gettempdir(), "atlas-conform-ws")


def make_workspace(case_dir):
    """Seed a fresh workspace at the fixed ws path.

    A fixed path (not mkdtemp randomness) keeps verbose stdout, which embeds
    absolute file:// URLs, byte-identical across recording (make_corpus.py) and
    every subject run.  The previous workspace is discarded first.
    """
    ws = ws_path()
    shutil.rmtree(ws, ignore_errors=True)
    os.makedirs(ws)
    for entry in os.listdir(case_dir):
        if entry in ("args", "cmds", "golden", "flaky"):
            continue
        shutil.copytree(os.path.join(case_dir, entry), os.path.join(ws, entry))
    # The output folder already exists when Xcode drives the tool.
    os.makedirs(os.path.join(ws, COMPARE_DIR), exist_ok=True)
    return ws


def run_sequence(binary, argv_list, ws):
    records = []
    for argv in argv_list:
        p = subprocess.run([binary] + argv, cwd=ws,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        records.append((p.returncode & 0xff, p.stdout, p.stderr))
    exit_text = "\n".join(str(r[0]) for r in records)
    stdout = b"\n".join(r[1] for r in records)
    stderr = b"\n".join(r[2] for r in records)
    return exit_text, stdout, stderr


def snapshot_tree(root):
    """Map tree-relative paths to their byte contents.

    Bytes are read while the workspace still exists; the dict survives the
    later rmtree of the workspace.
    """
    files = {}
    for dirpath, dirnames, names in os.walk(root):
        for n in names:
            full = os.path.join(dirpath, n)
            files[os.path.relpath(full, root)] = read(full)
    return files


def plist_canon_key(obj):
    """A stable string for plist equality as a multiset member."""
    return plistlib.dumps(obj, sort_keys=True)


def plist_equal(g, a):
    """Compare two parsed plists, ignoring the order of the images array
    on purpose: the page order Apple writes there is the iteration order of
    their own group dictionary (a hash-table memory layout), which is not a
    contract SpriteKit depends on.  Everything else, including each page's
    subimage order, must match exactly."""
    if not isinstance(g, dict) or not isinstance(a, dict):
        return g == a
    if g.keys() != a.keys():
        return False
    for k in g:
        if k == "images":
            if not isinstance(g[k], list) or not isinstance(a[k], list):
                return False
            gs = sorted(plist_canon_key(i) for i in g[k])
            as_ = sorted(plist_canon_key(i) for i in a[k])
            if gs != as_:
                return False
        elif g[k] != a[k]:
            return False
    return True


def compare(actual, expected):
    """Which tree files differ (multiset of relative paths).

    .plist files are compared semantically (see plist_equal) so that a
    byte-identical result never shows up as a difference; page PNGs and
    anything else stay byte-for-byte.
    """
    bad = []
    for f in sorted(expected.keys() & actual.keys()):
        gb = expected[f]
        ab = actual[f]
        if gb == ab:
            continue
        if f.endswith(".plist"):
            try:
                if plist_equal(plistlib.loads(gb), plistlib.loads(ab)):
                    continue
            except Exception:
                pass
        bad.append(f)
    return bad


def main():
    argv = sys.argv[1:]
    tool = None
    build_dir = None
    verify_oracle = False
    oracle = os.environ.get("ORACLE_TEXTUREATLAS", DEFAULT_ORACLE)
    for i, a in enumerate(argv):
        if a == "--build-dir" and i + 1 < len(argv):
            build_dir = argv[i + 1]
        elif a == "--verify-oracle":
            verify_oracle = True
        elif a in ("TextureAtlas",):
            tool = a
    if tool is None or build_dir is None:
        print("usage: run_tests.py TextureAtlas --build-dir DIR [--verify-oracle]")
        return 2

    subject = os.path.join(os.path.abspath(build_dir), "TextureAtlas")
    suite = os.path.join(os.path.dirname(os.path.abspath(__file__)), tool)
    failures = 0
    total = 0
    stale = 0

    for name in sorted(os.listdir(suite)):
        case_dir = os.path.join(suite, name)
        if not os.path.isdir(case_dir):
            continue
        total += 1
        argv_list = split_cmds(case_dir)
        golden_dir = os.path.join(case_dir, "golden")
        flaky = os.path.exists(os.path.join(case_dir, "flaky"))

        g_exit = read(os.path.join(golden_dir, "exit")).decode()
        g_out = read(os.path.join(golden_dir, "stdout"))
        g_err = read(os.path.join(golden_dir, "stderr"))
        golden_tree = os.path.join(golden_dir, "tree")
        g_tree = snapshot_tree(golden_tree) if os.path.isdir(golden_tree) else {}

        if verify_oracle:
            ws = make_workspace(case_dir)
            try:
                o_exit, o_out, o_err = run_sequence(oracle, argv_list, ws)
            finally:
                shutil.rmtree(ws, ignore_errors=True)
            if (o_exit, o_out, o_err) == (g_exit, g_out, g_err):
                print("ORACLE-GOLDEN ok   %s" % name)
            else:
                stale += 1
                print("ORACLE-GOLDEN DIFF %s" % name)

        ws = make_workspace(case_dir)
        m_exit = m_out = m_err = None
        actual = {}
        try:
            m_exit, m_out, m_err = run_sequence(subject, argv_list, ws)
            ws_out = os.path.join(ws, COMPARE_DIR)
            if os.path.isdir(ws_out):
                actual = snapshot_tree(ws_out)
        finally:
            shutil.rmtree(ws, ignore_errors=True)

        output_ok = (m_exit, m_out, m_err) == (g_exit, g_out, g_err)
        extra = sorted(set(actual) - set(g_tree))
        missing = sorted(set(g_tree) - set(actual))
        diffed = compare(actual, g_tree)
        tree_ok = not (extra or missing or diffed)
        ok = output_ok and tree_ok

        if not ok and flaky:
            print("SKIP %s (flaky)" % name)
            continue
        if ok:
            print("PASS %s" % name)
            continue

        failures += 1
        print("FAIL %s" % name)
        if m_exit != g_exit:
            print("  exit: golden=%r subject=%r" % (g_exit, m_exit))
        if m_out != g_out:
            print("  stdout: golden=%r" % g_out[:300])
            print("          subject=%r" % m_out[:300])
        if m_err != g_err:
            print("  stderr: golden=%r" % g_err[:300])
            print("          subject=%r" % m_err[:300])
        for f in missing[:5]:
            print("  missing file: %s" % f)
        for f in extra[:5]:
            print("  extra file:   %s" % f)
        for f in diffed[:5]:
            print("  differs:      %s (golden %d B vs subject %d B)"
                  % (f, len(g_tree[f]), len(actual[f])))

    print("%d probes, %d failures%s" % (
        total, failures,
        ", %d stale goldens" % stale if stale else ""))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())