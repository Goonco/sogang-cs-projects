#!/usr/bin/python3
import sys, os, subprocess
from os import path
from subprocess import PIPE


ROOT_DIR = path.dirname(path.abspath(__file__))
CONFIG_FILE = "config"
TIMEOUT = 3
DELAY_PENALTY = 0.8
MARKER_SIG = "================"


# Exception must be handled by the caller.
def run_cmd(cmd_str, check=True):
    args = cmd_str.split()
    p = subprocess.run(args, check=check, stdout=PIPE, stderr=PIPE,
                       timeout=TIMEOUT)
    return "".join(map(chr, p.stdout))


def run_make(problem_dir, target):
    try:
        orig_cwd = os.getcwd()
        os.chdir(problem_dir)
        run_cmd("make %s" % target, check=False) # 'make' may fail.
        os.chdir(orig_cwd)
    except Exception as e:
        print("Unexpected exception: %s" % str(e))
        exit(1)


def check(problem_name, submit_files, tc_num, point, is_delay):
    problem_dir = path.join(ROOT_DIR, problem_name)

    # If any of the file is missing, it means no submission.
    for submit_file in submit_files:
        if not path.isfile(path.join(problem_dir, submit_file)):
            return (" ", 0.0)

    # Build the problem directory.
    run_make(problem_dir, "clean")
    run_make(problem_dir, "")
    executable = path.join(problem_dir, problem_name + ".bin")
    if not path.isfile(executable):
        return ("C" * tc_num, 0.0)
    try:
        output = run_cmd(executable)
        grading_str = output.split(MARKER_SIG)[-1].strip()
    except subprocess.TimeoutExpired:
        grading_str = "T" * tc_num

    ratio = float(grading_str.count("O")) / tc_num
    obtained_point = point * ratio
    if is_delay:
        grading_str += " (Delay)"
        obtained_point *= DELAY_PENALTY
    return grading_str, obtained_point


def parse_config():
    f = open(path.join(ROOT_DIR, CONFIG_FILE))
    problem_list = []
    for line in f:
        tokens = line.strip().split()
        problem_name = tokens[0]
        submit_files = tokens[1].split(",")
        point = int(tokens[2])
        tc_num = int(tokens[3])
        problem_list.append((problem_name, submit_files, point, tc_num))
    f.close()
    return problem_list


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

    problem_list = parse_config()
    total_point = 0.0
    for (problem_name, submit_files, point, tc_num) in problem_list:
        if not csv_flag:
            print("[*] Grading %s ..." % problem_name)
        grading_str, obtained_point = \
                check(problem_name, submit_files, tc_num, point, delay_flag)
        if csv_flag:
            print("%s, %.1f, " % (grading_str, obtained_point), end="")
        else:
            print("[*] Result: %s" % grading_str)


if __name__ == "__main__":
    main()
