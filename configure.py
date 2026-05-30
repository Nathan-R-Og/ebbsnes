
import subprocess
from glob import glob
import os
import shutil
import tools.yamlSplit
import tools.nesToSnes

versions = ["jp", "us"]

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Configure the project")
    parser.add_argument(
        "-d",
        "--disassemble",
        help="Disassemble the rom's banks",
        action="store_true",
    )

    args = parser.parse_args()

    if os.path.exists("split/"):
        shutil.rmtree("split/")

    if os.path.exists("artifacts/"):
        shutil.rmtree("artifacts/")

    anySplit = False
    for version in versions:
        # the call to `doSplit()` has to come first, otherwise once one split
        # succeeds, it will short-circuit and not evaluate `doSplit()` again
        anySplit = tools.yamlSplit.doSplit(version) or anySplit
    if not anySplit:
        raise(Exception("ERROR: did not find any ROM files to extract. Please put a clean\n"
              "MOTHER or Earthbound ROM in the same directory as configure.py"))

    os.makedirs("artifacts/us/chr/")
    print("generating snes assets..")
    tools.nesToSnes.do("split/us/chr/title.bin", "artifacts/us/chr/title.2bpp", 2)
    tools.nesToSnes.do("split/us/chr/earth.bin", "artifacts/us/chr/earth.4bpp", 4, 0)