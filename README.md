# StoryboardUtil

xcode 프로젝트 - Build phases - New Run Script Phases - shell에 다음 스크립트 추가

chmod 775 ~/Library/Developer/Xcode/DerivedData/Project/SourcePackages/checkouts/StoryboardUtil/StoryboardList.txt
find "${SRCROOT}" -name "*.storyboard" -exec basename {} \; > "${BUILD_DIR%Build/*}SourcePackages/checkouts/StoryboardUtil/StoryboardList.txt"


만약, storyboard로 사용하지 않는 (ex. LaunchScreen) 스토리보드가 있다면, 명시적으로 설정할 수 있음 (default ["LaunchScreen"]로 설정되어 있음) 

StoryboardUtil.shared.excludeBoards = ["LaunchScreen"]
