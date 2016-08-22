#!/usr/bin/env bash
# author: Lefteris Karapetsas <lefteris@refu.co>
#
# Just upload the generated .rb file to homebrew elementrem

echo ">>> Starting the script to upload .rb file to homebrew elementrem"
rm -rf homebrew-elementrem
git clone git@github.com:elementrem/homebrew-elementrem.git
cp webthree-umbrella/build/cpp-elementrem.rb homebrew-elementrem
cd homebrew-elementrem
git add . -u
git commit -m "update cpp-elementrem.rb"
git push origin
cd ..
rm -rf homebrew-elementrem
echo ">>> Succesfully uploaded the .rb file to homebrew elementrem"
