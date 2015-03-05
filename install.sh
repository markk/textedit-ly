#!/bin/bash

if [ -z "$1" ]; then
    BinPath=/home/$(whoami)/.local/bin
else
    BinPath=$1
fi

if [ ! -d "$BinPath" ]; then
    echo "Directory $BinPath does not exist!"
    echo "Please specify an existing install directory."
    exit 1
fi

echo "Installing textedit.py to $BinPath ..."
cp textedit.py $BinPath
chmod +x $BinPath/textedit.py

TmpDir=$(mktemp -d)
sed "s#%%BINPATH%%#$BinPath#" textedit.desktop > $TmpDir/textedit.desktop
echo "Installing desktop menu file ..."
xdg-desktop-menu install --novendor $TmpDir/textedit.desktop
echo "Registering mime type association ..."
xdg-mime default textedit.desktop x-scheme-handler/textedit
rm -rf $TmpDir

ConfFile=/home/$(whoami)/.config/lytextedit.cfg
# clean up from previous install file locations
if [ -f "~/.lytextedit.cfg" ]; then
    echo "Moving previous config file ..."
    cp -v "~/.lytextedit.cfg" "$ConfFile"
    rm "~/.lytextedit.cfg"
fi
rm -f ~/.lytextedit.log

# don't overwrite existing config
test -f $ConfFile && exit

echo "Creating config file ..."
cat > $ConfFile << EOF
[editor]
editor = gvim
command = --remote +:{line}:normal{start} "{file}"

[script]
verbose = true
focus = false
EOF

