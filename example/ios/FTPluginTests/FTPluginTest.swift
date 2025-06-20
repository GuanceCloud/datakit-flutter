//
//  FTPluginTest.swift
//  FTTests
//
//  Created by hulilei on 2025/6/19.
//

import XCTest
import ft_mobile_agent_flutter
import Flutter
import FTTest
import FTMobileSDK

final class FTPluginTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
       
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSdkConfigEmpty() throws {
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.sdkConfigEmptyDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    func testSdkConfig() throws {
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.sdkConfigDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    func testTraceConfig() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.traceConfigDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftTraceConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    func testTraceConfigEmpty() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.traceConfigEmptyDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftTraceConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    func testLogConfig() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.logConfigDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftLogConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    func testLogConfigEmpty() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.logConfigEmptyDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftLogConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    
    func testRumConfig() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.logConfigDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftRumConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    func testRumConfigEmpty() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = TestUtils.logConfigEmptyDict()
        let methodCall = FlutterMethodCall.init(methodName: "ftRumConfig", arguments: arguments)
        
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                XCTAssertTrue(result == true)
            }
        }
    }
    func sdkInit(){
        let config = FTMobileConfig(datakitUrl: "aaa")
        FTMobileAgent.start(withConfigOptions: config)
    }

}
