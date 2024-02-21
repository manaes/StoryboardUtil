# StoryboardUtil

A description of this package.

find "${SRCROOT}" -name "*.storyboard" -exec basename {} \; > "${BUILD_DIR%Build/*}SourcePackages/checkouts/StoryboardUtil/StoryboardList.txt"

chmod 775 ~/Library/Developer/Xcode/DerivedData/Project/SourcePackages/checkouts/StoryboardUtil/StoryboardList.txt
