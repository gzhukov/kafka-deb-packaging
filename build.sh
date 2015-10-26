#!/bin/bash
# 2015-Mar-18 Updated to latest Kafka stable: 0.8.2.1
set -e
set -u
name=kafka
version=0.8.2.1
scala_version=2.10
description="Apache Kafka is a distributed publish-subscribe messaging system."
url="https://kafka.apache.org/"
arch="all"
section="misc"
license="Apache Software License 2.0"
package_version=$1
bin_package="kafka_${scala_version}-${version}.tgz"
download_url="http://apache-mirror.rbc.ru/pub/apache/kafka/${version}/${bin_package}"
log4j_extras_url="http://central.maven.org/maven2/log4j/apache-log4j-extras/1.2.17/apache-log4j-extras-1.2.17.jar"
origdir="$(pwd)"

#_ MAIN _#
rm -rf ${name}*.deb
if [[ ! -f "${bin_package}" ]]; then
  wget ${download_url}
  wget ${log4j_extras_url}
fi
mkdir -p tmp && pushd tmp
rm -rf kafka
mkdir -p kafka
cd kafka
mkdir -p build/usr/lib/kafka
cp -r ${origdir}/files/etc build/etc
cp -r ${origdir}/files/deb ./deb

tar zxf ${origdir}/${bin_package} && cd kafka_${scala_version}-${version}
mv * ../build/usr/lib/kafka
mv ${origdir}/apache-log4j-extras*.jar ../build/usr/lib/kafka/libs/
cd ../build

fpm -t deb \
    -n ${name} \
    -v ${version}-${package_version} \
    --description "${description}" \
    --url="{$url}" \
    -a ${arch} \
    --category ${section} \
    --vendor "" \
    --license "${license}" \
    -m "Gleb Zhukov <gzhukov@iponweb.net>" \
    --after-install "../deb/postinst" \
    --after-remove "../deb/postrm" \
    --before-remove "../deb/prerm" \
    --prefix=/ \
    -s dir \
    -- .
mv kafka*.deb ${origdir}
popd
