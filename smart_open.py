import sys
from contextlib import contextmanager

@contextmanager
def smart_open(filename, mode="rt", encoding=None, **kwds):
    """
    a smart open function that could:
    1. open normal file, gzip/bz2 file, "-" for stdin/stdout
    2. support both read and write

    filename: file name, "-" for stdin/stdout
    mode:     default to "rt", use "wt" for writing
    encoding: default to None, use appropriate encoding when necessary.

    Usage:
    with smart_open("-") as f:
        print(f.read())
    with smart_open("a.gz") as f:
        print(f.read())
    with smart_open("a.bz2") as f:
        print(f.read())

    with smart_open("abc.gz", mode="wt") as f:
        f.write("line1\n")
    with smart_open("-", mode="wt") as f:
        f.write("line2\n")
        f.write("中文\n")

    """

    if isinstance(filename, str):
        if filename == "-":
            if "r" in mode:
                f = sys.stdin
            elif "w" in mode:
                f = sys.stdout
            else:
                raise Exception(f"mode '{mode}' should have either 'r' or 'w'.\n")
        elif filename.endswith(".gz"):
            import gzip
            f = gzip.open(filename, mode=mode, encoding=encoding, **kwds)
        elif filename.endswith(".bz2"):
            import bz2
            f = bz2.open(filename, mode=mode, encoding=encoding, **kwds)                        
        else:
            f = open(filename, mode=mode, encoding=encoding, **kwds)
    else:
        raise Exception(f"Doesn't recognize {filename}.\n")

    try:
        yield f
    finally:
        if not (f is sys.stdin or f is sys.stdout):
            f.close()

# ------------------------------------------------------------------------------
if __name__ == '__main__':
    # with smart_open("-") as f:
    # with smart_open("a.gz") as f:
    # with smart_open("a.bz2") as f:
    #     print(f.read())

    # with smart_open("abc.gz", mode="wt") as f:
    with smart_open("-", mode="wt") as f:
        f.write("line1\n")
        f.write("line2\n")
        f.write("中文\n")
