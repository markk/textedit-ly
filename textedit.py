#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys
import os
import subprocess
import shlex
from ConfigParser import ConfigParser

def parseurl(url):
    if ":" not in url:
        raise ValueError, "Could not parse url {0}".format(url)
    parts = url.split(":")
    if len(parts) != 5:
        raise ValueError, "Could not parse url {0}".format(url)
    fileposition = {
            "file":  parts[1].replace("///", "/"),
            "line":  int(parts[2]),
            "start": int(parts[3]),
            "end":   int(parts[4])
            }
    fileposition["exists"] = os.path.isfile(fileposition["file"])
    return fileposition

def invokeeditor(fileposition, config, logfile):
    cmd = [config.get("editor", "editor")]
    if "vim" in cmd[0]:
        fileposition["start"] += 1
    if fileposition:
        position = config.get("editor", "command").format(**fileposition)
        cmd += shlex.split(position)
    if logfile:
        logfile.write("running editor...\n")
        logfile.write(repr(cmd) + "\n")
    subprocess.call(cmd)
    if config.getboolean("script", "focus"):
        import time
        filename = fileposition["file"].split("/")[-1]
        focus = ["xdotool", "search", "--name", filename, "windowactivate"]
        if logfile:
            logfile.write("focussing editor...\n")
            logfile.write(repr(focus) + "\n")
        subprocess.call(focus)
        time.sleep(0.5)
        subprocess.call(focus)

def getconfig():
    config = ConfigParser()
    configfilename = os.path.expanduser("~/.lytextedit.cfg")
    config.read(configfilename)
    if not config.has_section("editor"):
        # write default config
        config.add_section("editor")
        config.set("editor", "editor", "gvim")
        config.set("editor", "command",
                "--remote +:{line}:normal{startchar} \"{file}\"")
        with open(configfilename, "w") as configfile:
            config.write(configfile)
    if not config.has_section("script"):
        # write default config
        config.add_section("script")
        config.set("script", "verbose", "true")
        config.set("script", "focus", "false")
        with open(configfilename, "w") as configfile:
            config.write(configfile)
    return config

if __name__ == "__main__":
    cmdline = sys.argv
    try:
        url = sys.argv[1]
    except IndexError:
        url = None
    config = getconfig()
    if config.getboolean("script", "verbose"):
        logfile = open(os.path.expanduser("~/.lytextedit.log"), "w")
        logfile.write("configuration read...\n")
    else:
        logfile = False
    if url:
        fileposition = parseurl(url)
        if logfile:
            logfile.write("url {0} parsed...\n".format(url))
            logfile.write(repr(fileposition) + "\n")
        if not fileposition["exists"]:
            if logfile:
                logfile.write("could not find file {0}\n".format(fileposition["file"]))
            fileposition = False
    else:
        fileposition = False
        if logfile:
            logfile.write("no url...\n")
    invokeeditor(fileposition, config, logfile)
    if logfile:
        logfile.close()
