#!/bin/bash

# Written by Nathan Sullivan <nathan@nightsys.net>

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

zookeeper_version="3.4.6"

# Remove old if it exists.
if [ -d ./zookeeper-pkg ]; then
	rm -rf ./zookeeper-pkg
fi
# Create a fresh directory.
mkdir ./zookeeper-pkg
cd ./zookeeper-pkg

# Pull down the release tarball.
wget "http://mirror.ventraip.net.au/apache/zookeeper/zookeeper-${zookeeper_version}/zookeeper-${zookeeper_version}.tar.gz"
tar xzvf "zookeeper-${zookeeper_version}.tar.gz"
cd "zookeeper-${zookeeper_version}"

# Fix the Provides line to be something sane, we don't all use Java 6.
sed -i -e 's/sun-java6-jre/java-runtime/' ./src/packages/deb/zookeeper.control/control
# Fix the init script for https://issues.apache.org/jira/browse/ZOOKEEPER-1937
sed -i -e 's/^#! \/bin\/sh$/#! \/bin\/bash/' ./src/packages/deb/init.d/zookeeper

# Use the zookeeper group instead of hadoop, feels cleaner.
sed -i -e 's/hadoop/zookeeper/g' ./src/packages/deb/zookeeper.control/preinst
sed -i -e 's/hadoop/zookeeper/g' ./src/packages/update-zookeeper-env.sh
# Fix the logic in preinst, that breaks user creation.
sed -i -e 's/ --groups/ -g/g' ./src/packages/deb/zookeeper.control/preinst
# TODOLATER - postrm should probably have a groupdel...
# Fix the JAVA_HOME selection to use whatever Java version is available on the system.
# Based on where the /usr/bin/java binary links back to.
java_home_path=$(readlink -e $(which java) | sed -e 's/\/bin\/java$//')
sed -i -e 's,JAVA_HOME=/usr/lib/jvm/java-6-sun/jre$,'"JAVA_HOME=${java_home_path}"',g' ./src/packages/update-zookeeper-env.sh

# Create our .deb
ant deb

# Copy the deb out of the source directory.
cp build/zookeeper*.deb ../
# Go back a directory.
cd ..

# List the .deb file created.
echo ""
pwd
echo ""
ls -la *.deb
echo ""

cd ..
echo "You can now copy the .deb file created into your remote repository."
