set -eo pipefail

cd ../
flutter pub upgrade
cd ios

pod install

function findSimulator(){
    TEST_SCHEME="$1"
    TEST_SIMULATOR="$2"
    
    # tvOS 测试用例
    SIMULATOR_INFO=$(xcodebuild -workspace Runner.xcworkspace -scheme ${TEST_SCHEME}  -showdestinations | grep "${TEST_SIMULATOR}" | grep "OS:" | head -1)
        
    # 检查是否找到模拟器
    if [ -z "$SIMULATOR_INFO" ]; then
    echo "Error: No ${TEST_SIMULATOR} found!"
    exit 1
    fi
    
    # 提取模拟器的系统版本和 ID
    SIMULATOR_OS=$(echo "$SIMULATOR_INFO" | awk -F 'OS:' '{print $2}' | awk -F ',' '{print $1}')
    SIMULATOR_ID=$(echo "$SIMULATOR_INFO" | awk -F 'id:' '{print $2}' | awk -F ',' '{print $1}')
    
    # 构建 SIMULATOR_DESTINATION 字符串
    SIMULATOR_DESTINATION="platform=${TEST_SIMULATOR},OS=$SIMULATOR_OS,id=$SIMULATOR_ID"
    
    # 检查返回值是否为空
    if [ -z "$SIMULATOR_DESTINATION" ]; then
    echo "Error: Failed to get ${TEST_SIMULATOR} destination."
    exit 1
    fi
    
    echo "$SIMULATOR_DESTINATION"
}

IOS_DESTINATION=$(findSimulator "FTPluginTests" "iOS Simulator")

echo "$IOS_DESTINATION"
#
### 测试 iOS
xcodebuild test -workspace Runner.xcworkspace \
-scheme FTPluginTests \
-only-testing FTPluginTests \
-destination "$IOS_DESTINATION" 

