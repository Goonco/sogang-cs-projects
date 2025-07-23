#!/usr/bin/python3
import sys, os, subprocess
from os import path
from subprocess import PIPE


ROOT_DIR = path.dirname(path.abspath(__file__))
CONFIG_FILE = "config"
MAX_RUNTIME = 5
DELAY_PENALTY = 0.8
BUILD_DIRNAME="out"
TESTCASE_DIRNAME = "testcase"


def run_cmd(cmd_str, check=True, timeout=None):
    args = cmd_str.split()
    p = subprocess.run(args, check=check, stdout=PIPE, stderr=PIPE,
                       timeout=timeout)
    return "".join(map(chr, p.stdout))


def build(problem_name):
    try:
        orig_cwd = os.getcwd()
        os.chdir(path.join(ROOT_DIR, problem_name))
        run_cmd("dotnet build -o %s" % BUILD_DIRNAME)
        os.chdir(orig_cwd)
        return True
    except Exception as e:
        return False


def check(problem_name, submit_files, point, tc_num, is_delay):
    # If any of the file is missing, it means no submission.
    for submit_file in submit_files:
        src_path = path.join(ROOT_DIR, problem_name, submit_file)
        if not path.isfile(src_path): # Not submitted
            return (" ", 0.0)

    # Build the problem directory.
    build_success = build(problem_name)
    if not build_success:
        return ("C" * tc_num, 0.0)

    grading_str = ""
    # Now start the grading with each testcase file.
    binary = path.join(ROOT_DIR, problem_name, BUILD_DIRNAME, problem_name)
    tc_dir = path.join(ROOT_DIR, problem_name, TESTCASE_DIRNAME)
    for i in range(tc_num):
        ans_path = path.join(tc_dir, "ans-%d" % (i + 1))
        f = open(ans_path)
        ans = f.read()
        f.close()
        try:
            cmd = "%s %s/tc-%d" % (binary, tc_dir, i + 1)
            output = run_cmd(cmd, timeout=MAX_RUNTIME)
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
        # --delay or --normal option is hidden.
        print("Usage: %s" % sys.argv[0])
        exit(1)

    delay_flag = False
    csv_flag = False
    if len(sys.argv) == 2:
        csv_flag = True
        if sys.argv[1] == "--delay":
            delay_flag = True
        elif sys.argv[1] == "--normal":
            pass # Nothing to do if it's --normal.
        else:
            print("Invalid option: %s" % sys.argv[1])
            exit(1)

    problem_list = parse_config()
    for (problem_name, submit_files, point, tc_num) in problem_list:
        grading_str, obtained_point = \
            check(problem_name, submit_files, point, tc_num, delay_flag)
        if csv_flag:
            print("%s, %.1f, " % (grading_str, obtained_point), end="")
        else:
            print("[*] %s\t: %s" % (problem_name, grading_str))


if __name__ == "__main__":
    main()
