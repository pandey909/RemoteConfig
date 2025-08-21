//
//  RemoteConfigManager.swift
//
//
//  Created by Chiragdip Israni on 27/03/25.
//

import Combine
import Firebase
import FirebaseRemoteConfig
import Foundation

/// Class managing the remote configuration. Provides a façade for the Remote Config provider
public class RemoteConfigManager {

    // - MARK: Private properties
    /// The instance of `RemoteConfigType` used to interact with Firebase Remote Config.
    private var remoteConfig: RemoteConfigType?

    /// Contains references to subjects that need to be fired  when their configuration changes.
    private var subjects = [RemoteConfigKey: RemoteConfigPublisher]()

    // - MARK: Public properties
    /// Singleton instance of *RemoteConfigManager*
    public static let shared = RemoteConfigManager()

    // - MARK: Initialization
    private init() { }

    // - MARK: Public methods
    /// - Configure the remoteConfig either with Firebase or with Mock
    /// - Parameter remoteConfig: An instance conforming to `RemoteConfigType`.
    public func configure(remoteConfig: RemoteConfigType) {
        self.remoteConfig = remoteConfig
    }

    /// Set the minimum interval for fetching values from the remote config
    /// - Parameter fetchInterval: a *Double* representing the amount of seconds that need to pass before fetching updates on a remote config
    public func setFetchInterval(_ fetchInterval: Double) {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = fetchInterval
        self.remoteConfig?.configSettings = settings
    }

    /// Set the default values for the config from a plist
    /// - Parameter fromPlist: a *String* with the file name of the plist
    public func setDefaultValues(fromPlist plist: String) {
        self.remoteConfig?.setDefaults(fromPlist: plist)
    }

    /// Do an initial fetch of remote config values, and start listening for updates in real time
    /// - Parameter completionHandler: A closure called with `true` if the fetch and activation succeed, or `false` with an error if they fail.
    public func fetchConfig(completionHandler: @escaping (Bool, Error?) -> Void) {
        self.remoteConfig?.fetch { [weak self] status, error in
            if status == .success {
                self?.remoteConfig?.activate { changed, error in
                    if let error = error {
                        completionHandler(false, error)
                        return
                    }
                    if changed {
                        self?.firePublishers()
                    }
                    completionHandler(true, nil)
                }
            } else {
                completionHandler(false, error)
            }
        }
    }

    /// Adds a listener for configuration updates from Remote Config.
    /// - Parameter completionHandler: A closure that gets called when the config update completes.
    ///   - `Bool`: A flag indicating whether the config was successfully activated.
    ///   - `Error?`: An optional error if the update or activation failed.
    public func addConfigUpdateListener(completionHandler: @escaping (Bool, Error?) -> Void) {
        _ = self.remoteConfig?.addOnConfigUpdateListener { [weak self] configUpdate, error in
            guard let configUpdate, error == nil else {
                completionHandler(false, error)
                return
            }
            self?.remoteConfig?.activate { _, error in
                if let error = error {
                    completionHandler(false, error)
                    return
                }
                self?.firePublishers(forKeys: configUpdate.updatedKeys.sorted())
                completionHandler(true, nil)
            }
        }
    }

    /// Get a publisher for listening to changes for a specifier remote config value
    /// - Parameter key: a *RemoteConfigKey* containing the key to listen to value changes for
    /// - Returns: an *AnyPublisher* that will broadcast changes to the value of the specified key
    public func getPublisher<T>(forKey key: RemoteConfigKey) -> AnyPublisher<T?, Never>? {
        // based on the return type we will configure a publisher for that particular type
        if T.self == String.self {
            let subject = CurrentValueSubject<String?, Never>(self.getString(forKey: key))
            subjects[key] = RemoteConfigPublisher.string(subject)
            return subject.eraseToAnyPublisher() as? AnyPublisher<T?, Never>
        }

        if T.self == Bool.self {
            let subject = CurrentValueSubject<Bool?, Never>(self.getBool(forKey: key)) // swiftlint:disable:this discouraged_optional_boolean
            subjects[key] = RemoteConfigPublisher.bool(subject)
            return subject.eraseToAnyPublisher() as? AnyPublisher<T?, Never>
        }

        if T.self == Double.self {
            let subject = CurrentValueSubject<Double?, Never>(self.getDouble(forKey: key))
            subjects[key] = RemoteConfigPublisher.double(subject)
            return subject.eraseToAnyPublisher() as? AnyPublisher<T?, Never>
        }

        if T.self == [Any].self {
            let subject = CurrentValueSubject<[Any]?, Never>(self.getArray(forKey: key))
            subjects[key] = RemoteConfigPublisher.array(subject)
            return subject.eraseToAnyPublisher() as? AnyPublisher<T?, Never>
        }

        if T.self == [String: Any].self {
            let subject = CurrentValueSubject<[String: Any]?, Never>(self.getDictionary(forKey: key))
            subjects[key] = RemoteConfigPublisher.dictionary(subject)
            return subject.eraseToAnyPublisher() as? AnyPublisher<T?, Never>
        }
        return nil
    }

    /// Fire the publishers with keys in the list passed as a parameter and that have listeners
    /// - Parameter keys: an array of *String* objects with the keys corresponding to the publishers that need to be fired
    public func firePublishers(forKeys keys: [String]) {
        for keyString in keys {
            self.firePublisher(forKey: RemoteConfigKey(rawValue: keyString))
        }
    }

    // - MARK: Private methods
    /// Fire all the publishers that have listeners
    private func firePublishers() {
        guard let remoteConfig = remoteConfig else { return }
        self.firePublishers(forKeys: remoteConfig.allKeys(from: .remote))
    }

    /// Fire the publisher with key passed as a parameter as long as it has listeners
    /// - Parameter key: a *String* with the key corresponding to the publisher that needs to be fired
    private func firePublisher(forKey key: RemoteConfigKey) {
        guard let subject = self.subjects[key] else {
            return
        }
        switch subject {
        case .string(let subject):
            subject.send(self.getString(forKey: key))
        case .bool(let subject):
            subject.send(self.getBool(forKey: key))
        case .double(let subject):
            subject.send(self.getDouble(forKey: key))
        case .array(let subject):
            subject.send(self.getArray(forKey: key))
        case .dictionary(let subject):
            subject.send(self.getDictionary(forKey: key))
        }
    }

    /// Get an Int from the remote config
    /// - Parameter key: a *RemoteConfigKey* containing the key to retrieve the value for
    /// - Returns: an optional *Int* with the value for the provided key
    private func getValueAsInt(forKey key: RemoteConfigKey) -> Int? {
        guard let double = getDouble(forKey: key) else { return nil }
        return Int(double)
    }

    /// Get a String from the remote config
    /// - Parameter key: a *RemoteConfigKey* containing the key to retrieve the value for
    /// - Returns: an optional *String* with the value for the provided key
    private func getString(forKey key: RemoteConfigKey) -> String? {
        self.remoteConfig?.configValue(forKey: key.rawValue).stringValue
    }

    /// Get a Double from the remote config
    /// - Parameter key: a *RemoteConfigKey* containing the key to retrieve the value for
    /// - Returns: an optional *Double* with the value for the provided key
    private func getDouble(forKey key: RemoteConfigKey) -> Double? {
        self.remoteConfig?.configValue(forKey: key.rawValue).numberValue as? Double
    }

    private func getBool(forKey key: RemoteConfigKey) -> Bool? {  // swiftlint:disable:this discouraged_optional_boolean
        self.remoteConfig?.configValue(forKey: key.rawValue).boolValue
    }

    /// Get an Array from the remote config
    /// - Parameter key: a *RemoteConfigKey* containing the key to retrieve the value for
    /// - Returns: an optional *Array* with the value for the provided key
    private func getArray(forKey key: RemoteConfigKey) -> [Any]? {
        self.remoteConfig?.configValue(forKey: key.rawValue).jsonValue as? [Any]
    }

    /// Get a Dictionary from the remote config
    /// - Parameter key: a *RemoteConfigKey* containing the key to retrieve the value for
    /// - Returns: an optional *Dictionary* with the value for the provided key
    private func getDictionary(forKey key: RemoteConfigKey) -> [String: Any]? {
        self.remoteConfig?.configValue(forKey: key.rawValue).jsonValue as? [String: Any]
    }

}

extension RemoteConfigManager: RemoteConfigManagerType {

    public func getValue(forKey key: RemoteConfigKey) -> String? {
        self.getString(forKey: key)
    }

    public func getValue(forKey key: RemoteConfigKey) -> Double? {
        self.getDouble(forKey: key)
    }

    public func getValue(forKey key: RemoteConfigKey) -> Int? {
        guard let doubleValue = getDouble(forKey: key) else { return nil }
        return Int(doubleValue)
    }

    public func getValue(forKey key: RemoteConfigKey) -> Bool? { // swiftlint:disable:this discouraged_optional_boolean
        self.getBool(forKey: key)
    }

    public func getValue(forKey key: RemoteConfigKey) -> [Any]? {
        self.getArray(forKey: key)
    }

    public func getValue(forKey key: RemoteConfigKey) -> [String: Any]? {
        self.getDictionary(forKey: key)
    }

}

extension RemoteConfig: RemoteConfigType { }
