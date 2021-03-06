#!/bin/sh

PKG_DESC=
PKG_LONG_DESC=
PKG_AUTHOR=
PKG_EMAIL=
PKG_URL=
PKG_SCM=
PKG_SCM_URL=


# TODO 
PKG_LICENSE=
PKG_LOGO_URL=
PKG_DEPENDENCIES=
PKG_CFLAGS=
PKG_LFLAGS=

# File storing the package information
MANIFEST="manifest.xml"
echo "------------------------------------------"
echo "We require some information to update the $MANIFEST"
echo "------------------------------------------"
echo "Brief package description (Press ENTER when finished):"
read PKG_DESC

echo "Long description: "
read PKG_LONG_DESC
# REMOVE http:// since it is a bit messy to pass it through shell expansion
PKG_LONG_DESC=`echo $PKG_LONG_DESC | sed 's/http:\/\///g'`

echo "Author: "
read PKG_AUTHOR

echo "Author email: "
read PKG_EMAIL

echo "Url (optional):"
read PKG_URL
# REMOVE http:// since it is a bit messy to pass it through shell expansion
PKG_URL=`echo $PKG_URL | sed 's/http:\/\///g'`

# Yes, we only support git as SCM
PKG_SCM="git"
if test -n "$PKG_EXTRA_DEPENDENCIES"; then
    echo "Enter your dependencies as a comma separated list."
    echo "${PKG_EXTRA_DEPENDENCIES} have already been added for the bundle dependencies"
    echo "Press ENTER when finished:"
else
    echo "Enter your dependencies as a comma separated list."
    echo "Press ENTER when finished:"
fi
read PKG_DEPENDENCIES

if test -n "$PKG_EXTRA_DEPENDENCIES"; then
    if test -n "$PKG_DEPENDENCIES"; then
        PKG_DEPENDENCIES="$PKG_DEPENDENCIES,$PKG_EXTRA_DEPENDENCIES"
    else
        PKG_DEPENDENCIES="$PKG_EXTRA_DEPENDENCIES"
    fi
fi

# But if there is svn or mercurial support ever
# we can already prompt the user ;)
#echo "Version control system [git|svn|mercurial]: " 
#echo 1: git
#echo 2: svn
#echo 3: mercury

#while [ 1 ]
#        do 
#	echo "Select from list:"
#	read PKG_SCM
#	case $PKG_SCM in
#	1) PKG_SCM="git"
#	   break
#	   ;;
#	2) PKG_SCM="svn"
#	   break
#	   ;;
#	3) PKG_SCM="mercury"
#           break
#	   ;;
#	esac
#done

if [ -e CMakeLists.txt ]; then
    sed -i "s#\(PROJECT_DESCRIPTION\ \).*#\1\"$PKG_DESC\")#" CMakeLists.txt
fi
sed -i "s#dummy-brief-desc#$PKG_DESC#" $MANIFEST
sed -i "s#dummy-long-desc#$PKG_LONG_DESC#" $MANIFEST
sed -i "s#dummy-author#$PKG_AUTHOR#" $MANIFEST
sed -i "s#dummy-email#$PKG_EMAIL#" $MANIFEST
sed -i "s#dummy-url#http://$PKG_URL#" $MANIFEST
sed -i "s#dummy-version-control#$PKG_SCM#" $MANIFEST
sed -i "s#dummy-version-control-url#$PKG_SCM_URL#" $MANIFEST
sed -i "s#dummy-license#$PKG_LICENSE#" $MANIFEST
sed -i "s#dummy-logo-url#http://$PKG_LOGO_URL#" $MANIFEST

# Enter list of dependencies if there are any
if [ "$PKG_DEPENDENCIES" != "" ]
	then
	# Replace comma ','
	PKG_DEPENDENCIES=`echo $PKG_DEPENDENCIES | sed "s/,/ /g"`
	for dep in ${PKG_DEPENDENCIES}
		do
		# Use the </package> as a hook to place <depend package="pkg">
		sed -i "s#</package>#  <depend package=\"${dep}\"\ />\n</package>#" $MANIFEST
	done
fi

sed -i "s#dummy-cflags#$PKG_CFLAGS#" $MANIFEST
sed -i "s#dummy-lflags#$PKG_LFLAGS#" $MANIFEST

############################################
# Setup extension from manifest information
############################################
export PACKAGE_SHORT_NAME
export PKG_DESC
export PKG_LONG_DESC
export PKG_AUTHOR
export PKG_EMAIL
export PKG_URL
export PKG_LICENSE
if [ -e "prepare_ruby_c_extension.sh" ]; then
    sh prepare_ruby_c_extension.sh
fi
