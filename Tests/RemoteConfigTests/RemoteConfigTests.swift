//
//  RemoteConfigManagerTests.swift
//
//
//  Created by Chiragdip Israni on 27/03/25.
//

import Combine
import FirebaseRemoteConfig
@testable import RemoteConfig
import XCTest

class RemoteConfigManagerTests: XCTestCase {
    var remoteConfigManager: RemoteConfigManager?
    var mockRemoteConfig = MockRemoteConfig()

    override func setUp() {
        super.setUp()
        mockRemoteConfig = MockRemoteConfig()
        // Mock values for different types
        mockRemoteConfig.mockValues["forceUpgradeMessage"] = MockRemoteConfigValue(stringValue: "testValue")
        mockRemoteConfig.mockValues["remoteConfigDouble"] = MockRemoteConfigValue(numberValue: 42.0)
        mockRemoteConfig.mockValues["remoteConfigArray"] = MockRemoteConfigValue(jsonValue: ["item1", "item2"])
        mockRemoteConfig.mockValues["remoteConfigDict"] = MockRemoteConfigValue(jsonValue: ["key1": "value1", "key2": "value2"])
        mockRemoteConfig.mockValues["force_upgrade"] = MockRemoteConfigValue(boolValue: true)
        remoteConfigManager = RemoteConfigManager.shared
        RemoteConfigManager.shared.configure(remoteConfig: mockRemoteConfig)
    }

    func testSetFetchInterval() {
        remoteConfigManager?.setFetchInterval(1800)
        XCTAssertEqual(mockRemoteConfig.configSettings.minimumFetchInterval, 1800)
    }

    func testSetDefaultValues() {
        let plistName = "remote_config_defaults"
        remoteConfigManager?.setDefaultValues(fromPlist: plistName)
        XCTAssertEqual(mockRemoteConfig.defaultPlistFileName, plistName)
    }

    // Test for getting a String value
    func testGetStringValue() {
        let value: String? = remoteConfigManager?.getValue(forKey: .forceUpgradeMessage)
        XCTAssertEqual(value, "testValue")
    }

    // Test for getting a Double value
    func testGetDoubleValue() {
        let value: Double? = remoteConfigManager?.getValue(forKey: RemoteConfigKey(rawValue: "remoteConfigDouble"))
        XCTAssertEqual(value, 42.0)
    }

    // Test for getting an Array value
    func testGetArrayValue() {
        let value: [Any]? = remoteConfigManager?.getValue(forKey: RemoteConfigKey(rawValue: "remoteConfigArray"))
        XCTAssertEqual(value as? [String], ["item1", "item2"])
    }

    // Test for getting a Dictionary value
    func testGetDictionaryValue() {
        let value: [String: Any]? = remoteConfigManager?.getValue(forKey: RemoteConfigKey(rawValue: "remoteConfigDict"))
        XCTAssertEqual(value?["key1"] as? String, "value1")
        XCTAssertEqual(value?["key2"] as? String, "value2")
    }

    // Test for getting a Boolean value
    func testGetBoolValue() {
        let value: Bool? = remoteConfigManager?.getValue(forKey: .forceUpgrade) // swiftlint:disable:this discouraged_optional_boolean
        XCTAssertTrue(value ?? false)
    }

    func testDoubleValue() {
        let key = RemoteConfigKey(rawValue: "remoteConfigDouble")
        let expectedDoubleValue: Double = 42.0
        mockRemoteConfig.mockValues[key.rawValue] = MockRemoteConfigValue(numberValue: NSNumber(value: expectedDoubleValue))
        let value: Double? = remoteConfigManager?.getValue(forKey: key)
        XCTAssertEqual(value, expectedDoubleValue)
    }

    func testBoolValue() {
        let key = RemoteConfigKey(rawValue: "remoteConfigBool")
        let expectedBoolValue = true
        mockRemoteConfig.mockValues[key.rawValue] = MockRemoteConfigValue(boolValue: expectedBoolValue)
        let value: Bool? = remoteConfigManager?.getValue(forKey: key) // swiftlint:disable:this discouraged_optional_boolean
        XCTAssertEqual(value, expectedBoolValue)
    }

    // Publisher tests for each type
    func testGetStringPublisher() {
        let expectation = self.expectation(description: "String publisher should emit correct value")
        let key = RemoteConfigKey.forceUpgradeMessage

        let publisher = remoteConfigManager?.getPublisher(forKey: key) as AnyPublisher<String?, Never>?
        let cancellable = publisher?.sink { value in
            XCTAssertEqual(value, "testValue")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
        cancellable?.cancel()
    }

    func testGetDoublePublisher() {
        let expectation = self.expectation(description: "Double publisher should emit correct value")
        let key = RemoteConfigKey(rawValue: "remoteConfigDouble")

        let publisher = remoteConfigManager?.getPublisher(forKey: key) as AnyPublisher<Double?, Never>?
        let cancellable = publisher?.sink { value in
            XCTAssertEqual(value, 42.0)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
        cancellable?.cancel()
    }

    func testGetArrayPublisher() {
        let expectation = self.expectation(description: "Array publisher should emit correct value")
        let key = RemoteConfigKey(rawValue: "remoteConfigArray")

        let publisher = remoteConfigManager?.getPublisher(forKey: key) as AnyPublisher<[Any]?, Never>?
        let cancellable = publisher?.sink { value in
            XCTAssertEqual(value as? [String], ["item1", "item2"])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
        cancellable?.cancel()
    }

    func testGetDictionaryPublisher() {
        let expectation = self.expectation(description: "Dictionary publisher should emit correct value")
        let key = RemoteConfigKey(rawValue: "remoteConfigDict")

        let publisher = remoteConfigManager?.getPublisher(forKey: key) as AnyPublisher<[String: Any]?, Never>?
        let cancellable = publisher?.sink { value in
            XCTAssertEqual(value?["key1"] as? String, "value1")
            XCTAssertEqual(value?["key2"] as? String, "value2")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
        cancellable?.cancel()
    }

    func testGetBoolPublisher() {
        let expectation = self.expectation(description: "Bool publisher should emit correct value")
        let key = RemoteConfigKey.forceUpgrade

        let publisher = remoteConfigManager?.getPublisher(forKey: key) as AnyPublisher<Bool?, Never>? // swiftlint:disable:this discouraged_optional_boolean
        let cancellable = publisher?.sink { value in
            XCTAssertTrue(value ?? false)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
        cancellable?.cancel()
    }

    // Test fetching value that doesn't exist (nil case)
    func testGetValueNil() {
        let value: String? = remoteConfigManager?.getValue(forKey: .softUpgradeMessage) // Simulate an unknown key
        XCTAssertNil(value) // The key should not exist, returning nil
    }

    func testFetchSuccess() {
        let expectation = self.expectation(description: "Fetch and activate should succeed")
        mockRemoteConfig.shouldFetchSucceed = true
        mockRemoteConfig.shouldActivateSucceed = true
        remoteConfigManager?.fetchConfig { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error) // Ensure there's no error
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testFetchConfigFailure() {
        let expectation = self.expectation(description: "Fetch should fail")
        mockRemoteConfig.shouldFetchSucceed = false // Simulate a fetch failure
        remoteConfigManager?.fetchConfig { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testFetchAndActivateFailure() {
        let expectation = self.expectation(description: "Fetch and activate should fail")
        mockRemoteConfig.shouldFetchSucceed = false
        remoteConfigManager?.fetchConfig { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error) // Ensure error is returned
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testAddOnConfigUpdateListenerSuccess() {
        let expectation = self.expectation(description: "Listener and activate should succeed")
        mockRemoteConfig.shouldUpdateSucceed = true
        mockRemoteConfig.shouldActivateSucceed = true
        remoteConfigManager?.addConfigUpdateListener { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error) // Ensure there's no error
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testAddOnConfigUpdateListenerFailure() {
        let expectation = self.expectation(description: "Listener and activate should fail")
        mockRemoteConfig.shouldUpdateSucceed = false
        remoteConfigManager?.addConfigUpdateListener { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error) // Ensure error is returned
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testPublisherFiresOnValueChange() {
        let expectation1 = self.expectation(description: "Initial publisher value")
        let expectation2 = self.expectation(description: "Publisher should fire with updated value")
        // Set initial value in mock
        let key = RemoteConfigKey.forceUpgradeMessage
        mockRemoteConfig.mockValues[key.rawValue] = MockRemoteConfigValue(stringValue: "initialValue")
        // Safely unwrap the remoteConfigManager and publisher
        guard let remoteConfigManager = remoteConfigManager else {
            XCTFail("remoteConfigManager is nil")
            return
        }
        guard let publisher: AnyPublisher<String?, Never> = remoteConfigManager.getPublisher(forKey: key) else {
            XCTFail("Publisher for key \(key) is nil")
            return
        }
        // Subscribe to the publisher for the key
        var receivedValues: [String?] = []
        let cancellable = publisher.sink { value in
            receivedValues.append(value)
            // Verify the initial value
            if receivedValues.count == 1 {
                XCTAssertEqual(value, "initialValue")
                expectation1.fulfill()
            }
            // Verify the updated value
            else if receivedValues.count == 2 {
                XCTAssertEqual(value, "updatedValue")
                expectation2.fulfill()
            }
        }
        // Wait for initial value to be received
        wait(for: [expectation1], timeout: 1.0)
        // Simulate a value change in mock and fire publishers
        mockRemoteConfig.mockValues[key.rawValue] = MockRemoteConfigValue(stringValue: "updatedValue")
        remoteConfigManager.firePublishers(forKeys: [key.rawValue])
        // Wait for updated value to be received
        wait(for: [expectation2], timeout: 1.0)
        // Cancel the subscription
        cancellable.cancel()
    }

}
