#!/usr/bin/env python3

import fnmatch
import os
import re
import ntpath
import sys
import argparse

# WMP forbids tabs in .sqf; this repo has used them since its first commit, in all
# 85 files. Enforcing the WMP rule here would mean reformatting the entire codebase
# for no functional gain and destroying git blame, so that one rule is off by
# default. Everything else - delimiter balance, missing braces, the invalid-command
# list - is WMP's, unmodified, so fixes upstream port straight across.
# Set SQF_VALIDATOR_NO_TABS=1 to enforce it (e.g. if this repo ever converts).
ALLOW_TABS = os.environ.get("SQF_VALIDATOR_NO_TABS", "") == ""

INVALID_RUNTIME_COMMANDS = {
    # UI style is configured by the Rsc control class. Arma has no runtime
    # ctrlSetStyle SQF command; this previously passed delimiter checks and
    # failed only when the shared interaction display compiled in-game.
    "ctrlSetStyle": "not an Arma SQF runtime command; configure the control class instead",
}


def strip_comments_and_strings(content):
    """Blank comments/strings while preserving line numbers for token checks."""
    result = []
    index = 0
    state = "code"
    quote = ""
    while index < len(content):
        char = content[index]
        nxt = content[index + 1] if index + 1 < len(content) else ""
        if state == "code":
            if char in ('"', "'"):
                state = "string"
                quote = char
                result.append(" ")
            elif char == "/" and nxt == "/":
                state = "line_comment"
                result.extend((" ", " "))
                index += 1
            elif char == "/" and nxt == "*":
                state = "block_comment"
                result.extend((" ", " "))
                index += 1
            else:
                result.append(char)
        elif state == "string":
            result.append("\n" if char == "\n" else " ")
            if char == quote:
                if nxt == quote:
                    result.append(" ")
                    index += 1
                else:
                    state = "code"
        elif state == "line_comment":
            result.append("\n" if char == "\n" else " ")
            if char == "\n":
                state = "code"
        else:
            result.append("\n" if char == "\n" else " ")
            if char == "*" and nxt == "/":
                result.append(" ")
                index += 1
                state = "code"
        index += 1
    return "".join(result)

def validKeyWordAfterCode(content, index):
    keyWords = ["for", "do", "count", "each", "forEach", "else", "and", "not", "isEqualTo", "in", "call", "spawn", "execVM", "catch", "param", "select", "apply", "findIf", "remoteExec"];
    for word in keyWords:
        try:
            subWord = content.index(word, index, index+len(word))
            return True;
        except:
            pass
    return False

def check_sqf_syntax(filepath):
    bad_count_file = 0
    def pushClosing(t):
        closingStack.append(closing.expr)
        closing << Literal( closingFor[t[0]] )

    def popClosing():
        closing << closingStack.pop()

    with open(filepath, 'r', encoding='utf-8', errors='ignore') as file:
        content = file.read()

        # Store all brackets we find in this file, so we can validate everything on the end
        brackets_list = []

        # To check if we are in a comment block
        isInCommentBlock = False
        checkIfInComment = False
        # Used in case we are in a line comment (//)
        ignoreTillEndOfLine = False
        # Used in case we are in a comment block (/* */). This is true if we detect a * inside a comment block.
        # If the next character is a /, it means we end our comment block.
        checkIfNextIsClosingBlock = False

        # We ignore everything inside a string
        isInString = False
        # Used to store the starting type of a string, so we can match that to the end of a string
        inStringType = '';

        lastIsCurlyBrace = False
        checkForSemicolon = False
        onlyWhitespace = True

        # Extra information so we know what line we find errors at
        lineNumber = 1

        indexOfCharacter = 0
        # Parse all characters in the content of this file to search for potential errors
        for c in content:
            if (lastIsCurlyBrace):
                lastIsCurlyBrace = False
                # Test generates false positives with binary commands that take CODE as 2nd arg (e.g. findIf)
                checkForSemicolon = not re.search('findIf', content, re.IGNORECASE)

            if c == '\n': # Keeping track of our line numbers
                onlyWhitespace = True # reset so we can see if # is for a preprocessor command
                lineNumber += 1 # so we can print accurate line number information when we detect a possible error
            if (isInString): # while we are in a string, we can ignore everything else, except the end of the string
                if (c == inStringType):
                    isInString = False
            # if we are not in a comment block, we will check if we are at the start of one or count the () {} and []
            elif (isInCommentBlock == False):

                # This means we have encountered a /, so we are now checking if this is an inline comment or a comment block
                if (checkIfInComment):
                    checkIfInComment = False
                    if c == '*': # if the next character after / is a *, we are at the start of a comment block
                        isInCommentBlock = True
                    elif (c == '/'): # Otherwise, will check if we are in an line comment
                        ignoreTillEndOfLine = True # and an line comment is a / followed by another / (//) We won't care about anything that comes after it

                if (isInCommentBlock == False):
                    if (ignoreTillEndOfLine): # we are in a line comment, just continue going through the characters until we find an end of line
                        if (c == '\n'):
                            ignoreTillEndOfLine = False
                    else: # validate brackets
                        if (c == '"' or c == "'"):
                            isInString = True
                            inStringType = c
                        elif (c == '#' and onlyWhitespace):
                            ignoreTillEndOfLine = True
                        elif (c == '/'):
                            checkIfInComment = True
                        elif (c == '('):
                            brackets_list.append('(')
                        elif (c == ')'):
                            if (len(brackets_list) > 0 and brackets_list[-1] in ['{', '[']):
                                print("ERROR: Possible missing round bracket ')' detected at {0} Line number: {1}".format(filepath,lineNumber))
                                bad_count_file += 1
                            brackets_list.append(')')
                        elif (c == '['):
                            brackets_list.append('[')
                        elif (c == ']'):
                            if (len(brackets_list) > 0 and brackets_list[-1] in ['{', '(']):
                                print("ERROR: Possible missing square bracket ']' detected at {0} Line number: {1}".format(filepath,lineNumber))
                                bad_count_file += 1
                            brackets_list.append(']')
                        elif (c == '{'):
                            brackets_list.append('{')
                        elif (c == '}'):
                            lastIsCurlyBrace = True
                            if (len(brackets_list) > 0 and brackets_list[-1] in ['(', '[']):
                                print("ERROR: Possible missing curly brace '}}' detected at {0} Line number: {1}".format(filepath,lineNumber))
                                bad_count_file += 1
                            brackets_list.append('}')
                        elif (c == '\t' and not ALLOW_TABS):
                            print("ERROR: Tab detected at {0} Line number: {1}".format(filepath,lineNumber))
                            bad_count_file += 1

                        if (c not in [' ', '\t', '\n']):
                            onlyWhitespace = False

                        if (checkForSemicolon):
                            if (c not in [' ', '\t', '\n', '/']): # keep reading until no white space or comments
                                checkForSemicolon = False
                                if (c not in [']', ')', '}', ';', ',', '&', '!', '|', '='] and not validKeyWordAfterCode(content, indexOfCharacter)): # , 'f', 'd', 'c', 'e', 'a', 'n', 'i']):
                                    print("ERROR: Possible missing semicolon ';' detected at {0} Line number: {1}".format(filepath,lineNumber))
                                    bad_count_file += 1

            else: # Look for the end of our comment block
                if (c == '*'):
                    checkIfNextIsClosingBlock = True;
                elif (checkIfNextIsClosingBlock):
                    if (c == '/'):
                        isInCommentBlock = False
                    elif (c != '*'):
                        checkIfNextIsClosingBlock = False
            indexOfCharacter += 1

        if brackets_list.count('[') != brackets_list.count(']'):
            print("ERROR: A possible missing square bracket [ or ] in file {0} [ = {1} ] = {2}".format(filepath,brackets_list.count('['),brackets_list.count(']')))
            bad_count_file += 1
        if brackets_list.count('(') != brackets_list.count(')'):
            print("ERROR: A possible missing round bracket ( or ) in file {0} ( = {1} ) = {2}".format(filepath,brackets_list.count('('),brackets_list.count(')')))
            bad_count_file += 1
        if brackets_list.count('{') != brackets_list.count('}'):
            print("ERROR: A possible missing curly brace {{ or }} in file {0} {{ = {1} }} = {2}".format(filepath,brackets_list.count('{'),brackets_list.count('}')))
            bad_count_file += 1
        pattern = re.compile(r'\s*(/\*[\s\S]+?\*/)\s*#include')
        if pattern.match(content):
            print("ERROR: A found #include after block comment in file {0}".format(filepath))
            bad_count_file += 1

        executable = strip_comments_and_strings(content)
        for command, explanation in INVALID_RUNTIME_COMMANDS.items():
            for match in re.finditer(rf"(?i)\b{re.escape(command)}\b", executable):
                command_line = executable.count("\n", 0, match.start()) + 1
                print("ERROR: Invalid runtime command {0} at {1} Line number: {2} ({3})".format(command, filepath, command_line, explanation))
                bad_count_file += 1



    return bad_count_file

def check_trailing_commas(filepath):
    """Local addition, not from WMP.

    WMP's checker balances delimiters but does not reject a trailing comma before a
    closing bracket or brace - and that exact bug shipped here twice, breaking the
    mission at load with "Error Missing [". Both times it came from a script
    appending a closing "];" without stripping the comma off what had been the last
    element. Cheap to detect, so detect it.
    """
    bad = 0
    # RAW lines, with only trailing line-comments removed. Must NOT use
    # strip_comments_and_strings here: that blanks string CONTENTS, so
    # 'a, "Menu"' collapses to 'a,' plus spaces and rstrips to a false trailing
    # comma. That produced 44 false positives on a clean tree.
    with open(filepath, "r", errors="ignore") as handle:
        lines = [re.sub(r"//.*$", "", ln) for ln in handle.read().split("\n")]
    for index, line in enumerate(lines[:-1]):
        if not line.rstrip().endswith(","):
            continue
        nxt = lines[index + 1].strip()
        if nxt[:1] in ("]", "}") :
            print("ERROR: Trailing comma before '{0}' at {1} Line number: {2}"
                  .format(nxt[:1], filepath, index + 1))
            bad += 1
    return bad


def main():

    print("Validating SQF")

    sqf_list = []
    bad_count = 0

    parser = argparse.ArgumentParser()
    parser.add_argument('-m','--module', help='only search specified module addon folder', required=False, default="")
    args = parser.parse_args()

    # This repo IS a mission folder (no MissionScripts/ wrapper), so scan the whole
    # tree and skip what isn't ours. Runs correctly from the repo root or from
    # inside tools/ci.
    repo_root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
    scan_root = os.path.join(repo_root, args.module) if args.module else repo_root
    ignored = {".git", ".github", "__pycache__", "release", "node_modules"}

    for root, dirnames, filenames in os.walk(scan_root):
        dirnames[:] = [d for d in dirnames if d not in ignored]
        for filename in fnmatch.filter(filenames, '*.sqf'):
            sqf_list.append(os.path.join(root, filename))

    for filename in sqf_list:
        bad_count = bad_count + check_sqf_syntax(filename)
        bad_count = bad_count + check_trailing_commas(filename)


    print("------\nChecked {0} files\nErrors detected: {1}".format(len(sqf_list), bad_count))
    if (bad_count == 0):
        print("SQF validation PASSED")
    else:
        print("SQF validation FAILED")

    return bad_count

if __name__ == "__main__":
    sys.exit(main())
