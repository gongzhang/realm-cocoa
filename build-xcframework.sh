#!/bin/zsh
set -e

# find the first valid codesign identity
IDENTITY=$(security find-identity|grep -A 1 "Valid identities only"|head -n 2|tail -n 1|awk -F '"' '{print $2}')

echo "Build Realm XCframework"
echo "DEVELOPER_DIR=$DEVELOPER_DIR"
echo "IDENTITY=$IDENTITY"
echo "Do you want to continue? (y/n)"
read -r answer
case $answer in
    [yY][eE][sS]|[yY])
        echo "building..."
        ;;
    *)
        exit 0
        ;;
esac

sh build.sh xcframework

cd build

# sign the xcframework
codesign --timestamp -v --sign "$IDENTITY" Realm.xcframework
codesign --timestamp -v --sign "$IDENTITY" RealmSwift.xcframework

# create carthage zip
7z a -mx=9 Carthage.xcframework.zip Realm.xcframework RealmSwift.xcframework
cd ..

open build
echo "Remember to upload the Carthage.xcframework.zip to the release page:"
echo "  https://github.com/gongzhang/realm-cocoa/releases"
echo "Done."
