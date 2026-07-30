#!/usr/bin/env python3

import fnmatch
import os
import re
import ntpath
import sys
import argparse
from pathlib import Path

def check_config_style(filepath):
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
        checkForSemiColumn = False

        # Extra information so we know what line we find errors at
        lineNumber = 1

        indexOfCharacter = 0
        # Parse all characters in the content of this file to search for potential errors
        for c in content:
            if (lastIsCurlyBrace):
                lastIsCurlyBrace = False
            if c == '\n': # Keeping track of our line numbers
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
                        elif (c == '\t'):
                            # Existing Arma config files commonly use tab indentation. It has no
                            # parser or runtime meaning, so it is not a style failure.
                            pass

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
    return bad_count_file

def check_duplicates(filepath):
    """Local addition, not from WMP.

    Two config faults have broken this mission at load, and neither is a style issue
    so neither was covered: a duplicated class name among SIBLINGS ("s1Credits:
    Member already defined"), and a duplicated idc within one display, which does not
    error but silently makes displayCtrl return the wrong control.

    Scope-aware on purpose. A file-wide name check is wrong: mission.sqm legitimately
    declares Item0 131 times in different parents. Only siblings collide, so the key
    is (parent path, name). .sqm is skipped entirely - it is machine-generated by the
    editor and not ours to lint.
    """
    if Path(filepath).suffix.lower() == ".sqm":
        return 0
    text = Path(filepath).read_text(errors="ignore")
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"//[^\n]*", "", text)
    # Array initialisers use braces too - "colorBackground[] = {0,0,0,0};" - and their
    # closing brace popped a class off the scope stack, which corrupted every parent
    # path after the first colour in the file. Remove them before tokenising.
    text = re.sub(r"=\s*\{[^{}]*\}", "= 0", text)
    # Preprocessor colour macros are bare brace groups - "#define WALDO_ACCENT
    # {0.85,0.62,0.20,1}" - and quoted onLoad/onUnload bodies contain braces too.
    # Both popped class scopes, which is why displays looked like <root>.
    text = re.sub(r"^\s*#.*$", "", text, flags=re.M)
    text = re.sub(r'"[^"\n]*"', '""', text)

    bad, stack, seen_names, seen_idcs = 0, [], {}, {}
    # Only a class WITH a body opens a scope. "class RscText;" is a forward
    # declaration and pushing it would never be popped, mis-parenting the rest.
    for token in re.finditer(r'class\s+(\w+)\s*(?::\s*\w+\s*)?(\{)|(\})|idc\s*=\s*(-?\d+)', text):
        name, opened, closed, idc = token.groups()
        if name:
            parent = "/".join(stack)
            key = (parent, name)
            seen_names[key] = seen_names.get(key, 0) + 1
            if seen_names[key] == 2:
                print("ERROR: class '{0}' declared twice under '{1}' in {2}"
                      .format(name, parent or "<root>", filepath))
                bad += 1
            stack.append(name)
        elif closed and stack:
            stack.pop()
        elif idc is not None and int(idc) != -1:
            # Scoped to the outermost class, i.e. the display the control belongs to.
            display = stack[0] if stack else "<root>"
            key = (display, int(idc))
            seen_idcs[key] = seen_idcs.get(key, 0) + 1
            if seen_idcs[key] == 2:
                print("ERROR: idc {0} used twice in display '{1}' in {2}"
                      .format(idc, display, filepath))
                bad += 1
    return bad


def main():

    print("Validating Config Style")

    sqf_list = []
    bad_count = 0

    parser = argparse.ArgumentParser()
    parser.add_argument('-m','--module', help='only search specified module addon folder', required=False, default="")
    args = parser.parse_args()

    repository_root = Path(__file__).resolve().parents[2]
    scan_root = repository_root / args.module if args.module else repository_root
    ignored_directories = {".git", ".github", ".qa", "__pycache__", "release"}

    for root, dirnames, filenames in os.walk(scan_root):
      dirnames[:] = [name for name in dirnames if name not in ignored_directories]
      for filename in filenames:
        if Path(filename).suffix.lower() in {".cpp", ".hpp", ".ext", ".sqm"}:
          sqf_list.append(os.path.join(root, filename))

    for filename in sqf_list:
        bad_count = bad_count + check_config_style(filename)
        bad_count = bad_count + check_duplicates(filename)

    print("------\nChecked {0} files\nErrors detected: {1}".format(len(sqf_list), bad_count))
    if (bad_count == 0):
        print("Config validation PASSED")
    else:
        print("Config validation FAILED")

    return bad_count

if __name__ == "__main__":
    sys.exit(main())
