//
//  FTPluginTest.swift
//  FTTests
//
//  Created by hulilei on 2025/6/19.
//

import XCTest
import Flutter
@testable import ft_mobile_agent_flutter
@testable import FTTest
@testable import FTMobileSDK


final class FTPluginTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        FTLog.enable(true)
       
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        FTMobileAgent.shutDown()
    }

    func testSdkConfig() throws {
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.sdkConfigDict()
        let methodCall = FlutterMethodCall(methodName: SwiftAgentPlugin.METHOD_CONFIG, arguments: arguments)
        
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    func testSdkConfigEmpty() throws {
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.sdkConfigEmptyDict()
        let methodCall = FlutterMethodCall(methodName: SwiftAgentPlugin.METHOD_CONFIG, arguments: arguments)
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    func testSdkConfigSpecialKey() throws {
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.sdkConfigSpecialKeyDict()
        let methodCall = FlutterMethodCall(methodName: SwiftAgentPlugin.METHOD_CONFIG, arguments: arguments)
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    func testTraceConfig() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.traceConfigDict()
        let methodCall = FlutterMethodCall(methodName: SwiftAgentPlugin.METHOD_TRACE_CONFIG, arguments: arguments)
        
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    func testTraceConfigEmpty() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.traceConfigEmptyDict()
        let methodCall = FlutterMethodCall(methodName:  SwiftAgentPlugin.METHOD_TRACE_CONFIG, arguments: arguments)
        
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    func testLogConfig() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.logConfigDict()
        let methodCall = FlutterMethodCall(methodName:  SwiftAgentPlugin.METHOD_LOG_CONFIG, arguments: arguments)
        
        var testResult = false
        plugin.handle(methodCall) { result in
            if let result = result as? Bool{
                testResult = result
            }
        }
        XCTAssertTrue(testResult)
    }
    func testLogConfigEmpty() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.logConfigEmptyDict()
        let methodCall = FlutterMethodCall(methodName: SwiftAgentPlugin.METHOD_LOG_CONFIG, arguments: arguments)
        
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    
    func testRumConfig() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.rumConfigDict()
        let methodCall = FlutterMethodCall(methodName: SwiftAgentPlugin.METHOD_RUM_CONFIG, arguments: arguments)
        
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    func testRumConfigEmpty() throws {
        sdkInit()
        let plugin =  SwiftAgentPlugin()
        let arguments = FTTestUtils.rumConfigEmptyDict()
        let methodCall = FlutterMethodCall(methodName: SwiftAgentPlugin.METHOD_RUM_CONFIG, arguments: arguments)
        
        plugin.handle(methodCall) { result in
            var testResult = false
            if let result = result as? Bool{
                testResult = result
            }
            XCTAssertTrue(testResult)
        }
    }
    func sdkInit(){
        let config = FTMobileConfig(datakitUrl: FTTestUtils.fakeUrl)
        FTMobileAgent.start(withConfigOptions: config)
    }

}
