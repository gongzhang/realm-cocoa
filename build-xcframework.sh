#!/bin/zsh
set -e

# find the first valid codesign identity
IDENTITY=$(security find-identity|grep -A 1 "Valid identities only"|head -n 2|tail -n 1|awk -F '"' '{print $2}')

echo "Build Realm XCframework"
echo "DEVELOPER_DIR=$DEVELOPER_DIR"
echo "IDENTITY=$IDENTITY"

# NOTE: 注意目前仍然使用 Xcode 16.2 构建的 realm-core。
# Xcode 16.3 构建的 realm-core 在特定 ARCH 上出现 ld 无法链接 Decimal128 的问题。
# 从下面的问题可以确认 Xcode 16.3 对 Decimal128 做了修改：
#   https://github.com/realm/realm-swift/pull/8754/commits/29c05f28de85594f3608c7c25c3da2accbc6b27a
# 但 realm-core 仓库目前尚无相关议题，所以暂时使用 Xcode 16.2 构建的 realm-core。
cat dependencies.list
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
