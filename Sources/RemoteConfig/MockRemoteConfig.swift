//
//  MockRemoteConfig.swift
//
//
//  Created by Chiragdip Israni on 27/03/25.
//

import FirebaseRemoteConfig
import Foundation

// MARK: - Mock Classes
open class MockRemoteConfig: RemoteConfigType {
    public var configSettings: RemoteConfigSettings = RemoteConfigSettings()
    public var mockValues: [String: MockRemoteConfigValue] = [:]
    public var shouldFetchSucceed: Bool = true
    public var shouldActivateSucceed: Bool = true // Added for activate success
    public var shouldUpdateSucceed: Bool = true // Added for config update success
    public var completionHandler: ((RemoteConfigFetchStatus, Error?) -> Void)?
    public var defaultPlistFileName: String?

    public init() { }

    public func fetch(completionHandler: ((RemoteConfigFetchStatus, Error?) -> Void)?) {
        DispatchQueue.main.async {
            if self.shouldFetchSucceed {
                completionHandler?(.success, nil)
            } else {
                completionHandler?(.failure, NSError(domain: "FetchError", code: -1, userInfo: nil))
            }
        }
    }

    public func fetchAndActivate(completionHandler: ((RemoteConfigFetchAndActivateStatus, Error?) -> Void)?) {
        DispatchQueue.main.async {
            if self.shouldFetchSucceed && self.shouldActivateSucceed {
                completionHandler?(.successFetchedFromRemote, nil)
            } else {
                completionHandler?(.error, NSError(domain: "FetchAndActivateError", code: -1, userInfo: nil))
            }
        }
    }

    public func activate(completion: ((Bool, Error?) -> Void)?) {
        DispatchQueue.main.async {
            if self.shouldActivateSucceed {
                completion?(true, nil)
            } else {
                completion?(false, NSError(domain: "ActivateError", code: -1, userInfo: nil))
            }
        }
    }

    public func configValue(forKey key: String?) -> RemoteConfigValue {
        guard let key = key else { return MockRemoteConfigValue(stringValue: nil) }
        return mockValues[key] ?? MockRemoteConfigValue(stringValue: nil)
    }

    public func addOnConfigUpdateListener(remoteConfigUpdateCompletion listener: @escaping (RemoteConfigUpdate?, Error?) -> Void) -> ConfigUpdateListenerRegistration {
        DispatchQueue.main.async {
            if self.shouldUpdateSucceed {
                listener(MockRemoteConfigUpdate(updatedKeys: ["testKey"]), nil)
            } else {
                listener(nil, NSError(domain: "UpdateListenerError", code: -1, userInfo: nil))
            }
        }
        return ConfigUpdateListenerRegistration() // Stubbed
    }

    public func setDefaults(fromPlist fileName: String?) {
        defaultPlistFileName = fileName
    }

    public func allKeys(from source: RemoteConfigSource) -> [String] {
        return Array(mockValues.keys)
    }
}

public final class MockRemoteConfigValue: RemoteConfigValue {
    public override var stringValue: String? {
        return mockStringValue
    }

    public override var numberValue: NSNumber {
        return mockNumberValue ?? 0
    }

    public override var boolValue: Bool {
        return mockBoolValue
    }

    public override var dataValue: Data {
        return mockDataValue ?? Data()
    }

    public override var jsonValue: Any? {
        guard let data = mockDataValue else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }

    public override var source: RemoteConfigSource {
        return mockSource
    }

    var mockStringValue: String?
    var mockNumberValue: NSNumber?
    var mockBoolValue: Bool = false
    var mockDataValue: Data?
    var mockSource: RemoteConfigSource = .remote

    // Initializers for each data type
    public init(stringValue: String?) {
        self.mockStringValue = stringValue
    }

    public init(numberValue: NSNumber?) {
        self.mockNumberValue = numberValue
    }

    public init(boolValue: Bool) {
        self.mockBoolValue = boolValue
    }

    public init(dataValue: Data?) {
        self.mockDataValue = dataValue
    }

    public init(jsonValue: Any?) {
        if let jsonValue = jsonValue {
            self.mockDataValue = try? JSONSerialization.data(withJSONObject: jsonValue, options: [])
        }
    }

    public init(source: RemoteConfigSource) {
        self.mockSource = source
    }
}

final class MockRemoteConfigUpdate: RemoteConfigUpdate {
    private var _updatedKeys: [String]
    override var updatedKeys: Set<String> {
        return Set(_updatedKeys)
    }

    init(updatedKeys: [String]) {
        self._updatedKeys = updatedKeys
    }
}
