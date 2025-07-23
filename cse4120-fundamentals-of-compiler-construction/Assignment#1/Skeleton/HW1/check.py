#!/usr/bin/python3
import sys, os, subprocess
from os import path
from subprocess import PIPE


ROOT_DIR=path.dirname(path.abspath(__file__))
CONFIG_FILE = "config"
TIMEOUT = 3
DELAY_PENALTY = 0.8
SOURCE_DIRNAME = "src"
TESTCASE_DIRNAME = "testcase"
EXECUTABLE_NAME = "main.bin"


# Exception must be handled by the caller.
def run_cmd(cmd_str, check=True):
    args = cmd_str.split()
    p = subprocess.run(args, check=check, stdout=PIPE, stderr=PIPE,
                       timeout=TIMEOUT)
    return "".join(map(chr, p.stdout))


def run_make(target):
    try:
        orig_cwd = os.getcwd()
        os.chdir(ROOT_DIR)
        run_cmd("make %s" % target, check=False) # 'make' may fail.
        os.chdir(orig_cwd)
    except Exception as e:
        print("Unexpected exception: %s" % str(e))
        exit(1)


def check(src_files, tc_num, point, is_delay):
    # If any of the file is missing, it means no submission.
    for src_file in src_files:
        src_path = path.join(ROOT_DIR, SOURCE_DIRNAME, src_file)
        if not path.isfile(src_path):
            return (" ", 0.0)

    # Build the problem directory.
    run_make("clean")
    run_make("")
    executable = path.join(ROOT_DIR, EXECUTABLE_NAME)
    if not path.isfile(executable):
        return ("C" * tc_num, 0.0)

    grading_str = ""
    # Now start the grading with each testcase file.
    tc_dir = path.join(ROOT_DIR, TESTCASE_DIRNAME)
    for i in range(tc_num):
        tc_path = path.join(tc_dir, "tc-%d" % (i + 1))
        ans_path = path.join(tc_dir, "ans-%d" % (i + 1))
        f = open(ans_path)
        ans = f.read()
        f.close()
        try:
            output = run_cmd("%s %s" % (executable, tc_path))
            if ans.strip() == output.strip():
                grading_str += "O"
            else:
                grading_str += "X"
        except subprocess.TimeoutExpired:
            grading_str += "T"
        except subprocess.CalledProcessError as e:
            print(e)
            grading_str += "E"

    ratio = float(grading_str.count("O")) / tc_num
    obtained_point = point * ratio
    if is_delay:
        grading_str += " (Delay)"
        obtained_point *= DELAY_PENALTY
    return grading_str, obtained_point


def parse_config():
    f = open(path.join(ROOT_DIR, CONFIG_FILE))
    line = f.readline()
    f.close()
    tokens = line.strip().split(" ")
    src_files = tokens[1].split(",")
    tc_num = int(tokens[2])
    point = int(tokens[3])
    return (src_files, tc_num, point)


def main():
    if len(sys.argv) not in [1, 2]:
        # --delay|normal option is hidden.
        print("Usage: %s" % sys.argv[0])
        exit(1)

    delay_flag = False
    csv_flag = False
    if len(sys.argv) == 2:
        csv_flag = True
        if sys.argv[1] == "--delay":
            delay_flag = True
        elif sys.argv[1] != "--normal": # Nothing to do if it's --normal.
            print("Invalid option: %s" % sys.argv[2])
            exit(1)

    src_files, tc_num, point = parse_config()
    grading_str, obtained_point = check(src_files, tc_num, point, delay_flag)
    if csv_flag:
        print("%s, %.1f, " % (grading_str, obtained_point), end="")
    else:
        print("[*] Result: %s" % grading_str)


if __name__ == "__main__":
    main()
