#!/bin/sh
# environmental variable PACKAGE_SHORT_NAME and others need to be exported before calling this script
#

# Use templated in ext/, i.e ext/extconf.rb and ext/Rakefile
# configure them and apply them the main Rakefile and mv extconf.rb to a standard subfolder under ext
# which is required to work with rake-compiler lateron

# Check if a c-extension should be created at all
ANSWER=""
until [ "$ANSWER" = "y" ] || [ "$ANSWER" = "n" ] 
do
    echo "Do you want to develop a c-extension for this Ruby-package!? [y|n]"
	read ANSWER
	ANSWER=`echo $ANSWER | tr "[:upper:]" "[:lower:]"`
done

if [ "$ANSWER" = "n" ]; then
    rm -rf ext/
	echo "Skipping c-extension creation."
    return 0
fi

if [ "$PACKAGE_SHORT_NAME" = "" ]; then
    echo "ERROR: no project name given - check if you exported PACKAGES_SHORT_NAME before calling this script ($0). Cannot setup ruby c-extension"
    rm -rf ext/
else
    PKG_VERSION='0.0.1'
    echo "Preparing ruby c-extension for $PACKAGE_SHORT_NAME version ${PKG_VERSION}"
    # Create the package subfolder in ext/ as a standard required
    # by rake-compiler
    #
    # Set all the known fields as given in the manifest
    #

    sed -i "s#dummy-package-name#${PACKAGE_SHORT_NAME}#" ext/extconf.rb
    sed -i "s#dummy-package-name#${PACKAGE_SHORT_NAME}#" ext/core.cc

    sed -i "s#dummy-package-name#${PACKAGE_SHORT_NAME}#" ext/Rakefile
    sed -i "s#dummy-brief-desc#${PKG_DESC}#" ext/Rakefile
    sed -i "s#dummy-author#${PKG_AUTHOR}#" ext/Rakefile
    sed -i "s#dummy-email#${PKG_EMAIL}#" ext/Rakefile
    sed -i "s#dummy-version#${PKG_VERSION}#" ext/Rakefile

    # Create a rdoc based README 
    # the final template will use - yard and markdown to generate the actual documentation
    sed -i "s#dummy-package-name#${PACKAGE_SHORT_NAME}#" README.rdoc
    sed -i "s#dummy-brief-desc#${PKG_DESC}#" README.rdoc
    sed -i "s#dummy-long-desc#${PKG_LONG_DESC}#" README.rdoc
    sed -i "s#dummy-license#${PKG_LICENSE}#" README.rdoc
    sed -i "s#dummy-url#http://${PKG_URL}#" README.rdoc

    # Create default package structure required by rake-compiler
    mkdir -p ext/${PACKAGE_SHORT_NAME}/
    mv ext/extconf.rb ext/${PACKAGE_SHORT_NAME}/

    # Convert dots in package short name to underscores for filenaming
    PACKAGE_SHORT_NAME=`echo $PACKAGE_SHORT_NAME | sed "s#\.#_#"`
    mv ext/core.cc ext/${PACKAGE_SHORT_NAME}/${PACKAGE_SHORT_NAME}.cc

    # Replace the default rakefile
    mv ext/Rakefile Rakefile

    # Create history file
    PKG_INIT_DATE=`date +%Y-%m-%d`
    echo "=== $PKG_VERSION / $PKG_INIT_DATE" >> History.txt
    echo " * initial creation of package" >> History.txt

    # Create manifest
    # Exclude the existing shell scripts in the main folder and the git repositories
    find . -type f | grep -v sh$ | grep -v '\.git' | sed "s#^\./##" >> Manifest.txt
fi

