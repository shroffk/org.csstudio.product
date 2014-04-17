#!/bin/bash

# Check parameters
VERSION=$1
COMPATLINK=$2
MILESTONE=$3
NOTES=$4
BUILD_DIR="build"
if [! $# == 4 ]
then 
  echo You must provide the product version, compat link, milestone, notes \(e.g. \"prepare_release.sh 3.3.0 \"https://github\" \"https://github\" \"Some notes\"\"\)
exit -1
fi

echo ::: Prepare splash :::
java -jar $BUILD_DIR/ImageLabeler-1.0.jar $VERSION 462 53 plugins/org.csstudio.product/splash-template.bmp plugins/org.csstudio.product/splash.bmp
echo ::: Change about dialog version :::
echo 0=$VERSION > plugins/org.csstudio.product/about.mappings

echo ::: Updating plugin versions ::
mvn -Dtycho.mode=maven org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=$VERSION -Dartifacts=org.csstudio.product,org.csstudio.startup.intro

HTML="<h2>Version ${VERSION} - $(date +"%Y-%m-%d")</h2>
<ul>
<li>See specific application changelogs</li>
<li>${NOTES}</li>
<li><a href="${COMPATLINK}" shape="rect">Compatibility Notes and Know Bugs</a></li>
<li><a href="${MILESTONE}" shape="rect">Closed Issues</a></li>
</ul>"

sed -i "{N; s/\(<\/p>\)/\1\n\n${HTML}/}" plugins/org.csstudio.startup.intro/html/changelog.html

echo ::: Committing and tagging version $VERSION :::
git commit -a -m "Updating changelog, splash, manifests to version $VERSION"
git tag CSS-$VERSION
