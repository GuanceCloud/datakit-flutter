set -eo pipefail

cd ../
flutter pub upgrade
cd ios

pod install

function findSimulator(){
    TEST_SCHEME="$1"
    TEST_SIMULATOR="$2"
    
    # tvOS test cases
    SIMULATOR_INFO=$(xcodebuild -workspace Runner.xcworkspace -scheme ${TEST_SCHEME}  -showdestinations | grep "${TEST_SIMULATOR}" | grep "OS:" | head -1)
        
    # Check if simulator is found
    if [ -z "$SIMULATOR_INFO" ]; then
    echo "Error: No ${TEST_SIMULATOR} found!"
    exit 1
    fi
    
    # Extract simulator system version and ID
    SIMULATOR_OS=$(echo "$SIMULATOR_INFO" | awk -F 'OS:' '{print $2}' | awk -F ',' '{print $1}')
    SIMULATOR_ID=$(echo "$SIMULATOR_INFO" | awk -F 'id:' '{print $2}' | awk -F ',' '{print $1}')
    
    # Build SIMULATOR_DESTINATION string
    SIMULATOR_DESTINATION="platform=${TEST_SIMULATOR},OS=$SIMULATOR_OS,id=$SIMULATOR_ID"
    
    # Check if return value is empty
    if [ -z "$SIMULATOR_DESTINATION" ]; then
    echo "Error: Failed to get ${TEST_SIMULATOR} destination."
    exit 1
    fi
    
    echo "$SIMULATOR_DESTINATION"
}

IOS_DESTINATION=$(findSimulator "FTPluginTests" "iOS Simulator")

echo "$IOS_DESTINATION"
#
### Test iOS
xcodebuild test -workspace Runner.xcworkspace \
-scheme FTPluginTests \
-only-testing FTPluginTests \
-destination "$IOS_DESTINATION" 

