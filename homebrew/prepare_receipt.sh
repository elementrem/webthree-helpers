#/bin/bash

# this script should be run from build directory

VERSION=1 # eg 1.0rc2
NUMBER=1 # jenkins build number

# Detect whether we are running on a Yosemite or El Capitan machine, and generate
# an appropriately named ZIP file for the Homebrew receipt to point at.
if echo `sw_vers` | grep "10.11"; then
    OSX_VERSION=el_capitan
elif echo `sw_vers` | grep "10.10"; then
    OSX_VERSION=yosemite
else
    echo Unsupported OS X version.  We only support Yosemite and El Capitan
    exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        --version )
            shift
            VERSION=$1 
            ;;
        --number )
            shift
            NUMBER=$1
            ;;
    esac
    shift
done

# prepare template directory
rm -rf cpp-elementrem
mkdir cpp-elementrem
mkdir cpp-elementrem/$VERSION
p="../webthree-helpers/homebrew/"
cp ${p}homebrew.mxcl.cpp-elementrem.plist ${p}INSTALL_RECEIPT.json ${p}LICENSE ${p}README.md cpp-elementrem/$VERSION

# build umbrella project and move install directory to destination
#
# TODO - Except it isn't actually building it is? Maybe it used to
# at some point in the past? Does that mean that we are dependent
# on some previous build/install steps having happened by the time
# we run this script? Probably.
mkdir -p install
cp -rf install/* cpp-elementrem/$VERSION

# tar everything
NAME="cpp-elementrem-${VERSION}.${OSX_VERSION}.bottle.${NUMBER}.tar.gz"
tar -zcvf $NAME cpp-elementrem

# get variables
HASH=`git rev-parse HEAD`
SIGNATURE=`openssl sha1 ${NAME} | cut -d " " -f 2`

# Pull the current cpp-elementrem.rb file from Github.  We used to use a template file.
curl https://raw.githubusercontent.com/elementrem/homebrew-elementrem/master/cpp-elementrem.rb > cpp-elementrem.rb.in

# prepare receipt
if [ ${OSX_VERSION} == yosemite ]; then
    sed -e s/revision\ \=\>\ \'[[:xdigit:]][[:xdigit:]]*\'/revision\ \=\>\ \'${HASH}\'/g \
        -e s/version\ \'.*\'/version\ \'${VERSION}\'/g \
        -e s/sha1\ \'[[:xdigit:]][[:xdigit:]]*\'\ \=\>\ \:\yosemite/sha1\ \'${SIGNATURE}\'\ \=\>\ \:yosemite/g \
        -e s/revision[[:space:]][[:digit:]][[:digit:]]*/revision\ ${NUMBER}/g < cpp-elementrem.rb.in > "cpp-elementrem.rb"
else
    sed -e s/revision\ \=\>\ \'[[:xdigit:]][[:xdigit:]]*\'/revision\ \=\>\ \'${HASH}\'/g \
        -e s/version\ \'.*\'/version\ \'${VERSION}\'/g \
        -e s/sha1\ \'[[:xdigit:]][[:xdigit:]]*\'\ \=\>\ \:\el\_capitan/sha1\ \'${SIGNATURE}\'\ \=\>\ \:el\_capitan/g \
        -e s/revision[[:space:]][[:digit:]][[:digit:]]*/revision\ ${NUMBER}/g < cpp-elementrem.rb.in > "cpp-elementrem.rb"
fi
