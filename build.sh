#!/bin/bash

# PlayDate Compile
pdc -v source build/playdatebobble.pdx
cd build/
# Zip file
zip -r playdatebobble.pdx.zip playdatebobble.pdx
cd ../
