#!/bin/zsh
set -e

echo "Build Realm XCframework"
echo "DEVELOPER_DIR=$DEVELOPER_DIR"
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

# create carthage zip
cd build
7z a -mx=9 Carthage.xcframework.zip Realm.xcframework RealmSwift.xcframework
cd ..

open build
echo "Done."
