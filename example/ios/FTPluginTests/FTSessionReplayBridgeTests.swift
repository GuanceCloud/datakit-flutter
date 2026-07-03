//
//  FTSessionReplayBridgeTests.swift
//  FTPluginTests
//
//  Created by hulilei on 2026/6/12.
//

import XCTest
@testable import ft_session_replay_flutter
@testable import FTMobileSDK

final class FTSessionReplayBridgeTests: XCTestCase {
    override func tearDownWithError() throws {
        FTMobileAgent.shutDown()
    }

    func testSampleRateZeroNotSampled() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 0, sessionReplayOnErrorSampleRate: 0)

        postSessionReplayRUMContext()

        assertSessionReplaySampleState(bridge, .none)
    }

    func testSampleRateOneIsNormal() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 1, sessionReplayOnErrorSampleRate: 0)

        postSessionReplayRUMContext()

        assertSessionReplaySampleState(bridge, .normal)
    }

    func testOnErrorSampleRateOneIsError() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 0, sessionReplayOnErrorSampleRate: 1)

        postSessionReplayRUMContext()

        assertSessionReplaySampleState(bridge, .error)
    }

    func testSampleRateUpdateStartsSampling() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 0, sessionReplayOnErrorSampleRate: 0)
        postSessionReplayRUMContext()
        assertSessionReplaySampleState(bridge, .none)

        let expectation = expectation(description: "sample rate update")
        bridge.setSampleStateChangedHandler { context in
            if context["sampled"] as? Bool == true {
                expectation.fulfill()
            }
        }

        updateSessionReplaySampleRates(
            bridge,
            sampleRate: 1,
            sessionReplayOnErrorSampleRate: 0
        )
        postSessionReplaySampleRateUpdate()

        wait(for: [expectation], timeout: 1)
        assertSessionReplaySampleState(bridge, .normal)
    }

    func testRumErrorSessionMarksErrorReplay() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 1, sessionReplayOnErrorSampleRate: 0)

        postSessionReplayRUMContext(sampledForErrorSession: true)

        assertSessionReplaySampleState(bridge, .error)
    }

    func testSampleStateHandlerReceivesCurrentStateWhenAttachedAfterEvaluation() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 1, sessionReplayOnErrorSampleRate: 0)
        postSessionReplayRUMContext()
        assertSessionReplaySampleState(bridge, .normal)

        let expectation = expectation(description: "current sample state")
        bridge.setSampleStateChangedHandler { context in
            if context["sampled"] as? Bool == true,
               context["sampledForErrorReplay"] as? Bool == false {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSampleRateUpdateStopsSamplingAndNotifiesHandler() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 1, sessionReplayOnErrorSampleRate: 0)
        postSessionReplayRUMContext()
        assertSessionReplaySampleState(bridge, .normal)

        let expectation = expectation(description: "sample state changed to none")
        bridge.setSampleStateChangedHandler { context in
            if context["sampled"] as? Bool == false,
               context["sampledForErrorReplay"] as? Bool == false {
                expectation.fulfill()
            }
        }

        updateSessionReplaySampleRates(
            bridge,
            sampleRate: 0,
            sessionReplayOnErrorSampleRate: 0
        )
        postSessionReplaySampleRateUpdate()

        wait(for: [expectation], timeout: 1)
        assertSessionReplaySampleState(bridge, .none)
    }

    func testSetHasReplayPostsFalseWhenNotSampled() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 0, sessionReplayOnErrorSampleRate: 0)
        postSessionReplayRUMContext()
        assertSessionReplaySampleState(bridge, .none)

        let receiver = SessionReplayMessageReceiver(
            expectedKey: "sr_has_replay",
            expectation: expectation(description: "has replay message")
        )
        addMessageReceiver(receiver)
        defer {
            FTModuleManager.sharedInstance().remove(receiver)
        }

        bridge.setHasReplay([
            "viewId": "view-id",
            "hasReplay": true
        ])

        wait(for: [receiver.expectation], timeout: 1)
        let message = try XCTUnwrap(receiver.lastMessage)
        XCTAssertEqual(message["session_has_replay"] as? Bool, false)
        XCTAssertEqual(message["sampled_for_error_replay"] as? Bool, false)
        XCTAssertEqual(message["view_id"] as? String, "view-id")
    }

    func testWriteSegmentAndSaveImageResourceAreSkippedWhenNotSampled() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 0, sessionReplayOnErrorSampleRate: 0)
        postSessionReplayRUMContext()
        assertSessionReplaySampleState(bridge, .none)

        bridge.writeSegment([
            "viewId": "view-id",
            "segment": minimalSessionReplaySegment(viewId: "view-id")
        ])

        XCTAssertNil(bridge.value(forKey: "lastSegmentViewID") as? String)
        XCTAssertNil(bridge.saveImageResource([
            "bytes": Data([255, 0, 0, 255]),
            "width": 1,
            "height": 1
        ]))
    }

    func testSampleStateHandlerReceivesErrorReplayPayload() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 0, sessionReplayOnErrorSampleRate: 1)

        let expectation = expectation(description: "error replay sample state")
        bridge.setSampleStateChangedHandler { context in
            if context["sampled"] as? Bool == true,
               context["sampledForErrorReplay"] as? Bool == true {
                expectation.fulfill()
            }
        }

        postSessionReplayRUMContext()

        wait(for: [expectation], timeout: 1)
        assertSessionReplaySampleState(bridge, .error)
    }

    func testCurrentRUMContextFiltersLinkedRUMKeys() throws {
        let bridge = makeSessionReplayBridge(sampleRate: 1, sessionReplayOnErrorSampleRate: 0)
        bridge.setValue(["wgt_id"], forKey: "enableLinkRUMKeys")

        postSessionReplayRUMContext(bindInfo: [
            "wgt_id": "widget-id",
            "ignored_key": "ignored-value"
        ])

        let context = try XCTUnwrap(bridge.currentRUMContext())
        let globalContext = try XCTUnwrap(context["globalContext"] as? [String: String])
        let bindInfo = try XCTUnwrap(context["bindInfo"] as? [String: String])
        XCTAssertEqual(globalContext, ["wgt_id": "widget-id"])
        XCTAssertEqual(bindInfo, ["wgt_id": "widget-id"])
    }

    private enum SessionReplaySampleStateForTest: Int {
        case normal = 0
        case error = 1
        case none = 2
    }

    private func makeSessionReplayBridge(
        sampleRate: Double,
        sessionReplayOnErrorSampleRate: Double
    ) -> FTDefaultSessionReplayBridge {
        let bridge = FTDefaultSessionReplayBridge()
        flushSessionReplayMessageBus()
        updateSessionReplaySampleRates(
            bridge,
            sampleRate: sampleRate,
            sessionReplayOnErrorSampleRate: sessionReplayOnErrorSampleRate
        )
        return bridge
    }

    private func updateSessionReplaySampleRates(
        _ bridge: FTDefaultSessionReplayBridge,
        sampleRate: Double,
        sessionReplayOnErrorSampleRate: Double
    ) {
        bridge.setValue(NSNumber(value: Int(sampleRate * 100)), forKey: "sampleRate")
        bridge.setValue(NSNumber(value: Int(sessionReplayOnErrorSampleRate * 100)), forKey: "sessionReplayOnErrorSampleRate")
    }

    private func postSessionReplayRUMContext(
        sampledForErrorSession: Bool = false,
        bindInfo: [String: Any]? = nil
    ) {
        var context: [String: Any] = [
            "app_id": "app-id",
            "session_id": UUID().uuidString,
            "view_id": "view-id"
        ]
        if sampledForErrorSession {
            context["sampled_for_error_session"] = NSNumber(value: true)
        }
        if let bindInfo = bindInfo {
            context["bindInfo"] = bindInfo
        }
        FTModuleManager.sharedInstance().postMessage(
            withKey: "rum_context",
            message: context,
            sync: true
        )
    }

    private func postSessionReplaySampleRateUpdate() {
        FTModuleManager.sharedInstance().postMessage(
            withKey: "sr_sample_rate_update",
            message: [:],
            sync: true
        )
    }

    private func assertSessionReplaySampleState(
        _ bridge: FTDefaultSessionReplayBridge,
        _ expected: SessionReplaySampleStateForTest,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            bridge.sampleStateValue().rawValue,
            expected.rawValue,
            file: file,
            line: line
        )
    }

    private func flushSessionReplayMessageBus() {
        FTModuleManager.sharedInstance().postMessage(
            withKey: "ft_session_replay_test_flush",
            message: [:],
            sync: true
        )
    }

    private func addMessageReceiver(_ receiver: SessionReplayMessageReceiver) {
        FTModuleManager.sharedInstance().add(receiver)
        FTModuleManager.sharedInstance().postMessage(
            withKey: "ft_session_replay_test_flush_add_receiver",
            message: [:],
            sync: true
        )
    }

    private func minimalSessionReplaySegment(viewId: String) -> String {
        return """
        {"applicationID":"app-id","sessionID":"session-id","viewID":"\(viewId)","records":[{"type":10,"timestamp":1}]}
        """
    }
}

private final class SessionReplayMessageReceiver: NSObject, FTMessageReceiver {
    let expectation: XCTestExpectation
    private let expectedKey: String
    private(set) var lastMessage: [AnyHashable: Any]?

    init(expectedKey: String, expectation: XCTestExpectation) {
        self.expectedKey = expectedKey
        self.expectation = expectation
        super.init()
    }

    func receive(_ key: String, message: [AnyHashable: Any]) {
        guard key == expectedKey else {
            return
        }
        lastMessage = message
        expectation.fulfill()
    }
}
