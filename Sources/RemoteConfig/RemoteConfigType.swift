//
//  RemoteConfigType.swift
//
//
//  Created by Chiragdip Israni on 27/03/25.
//

import FirebaseRemoteConfig

/// Protocol defining the interface for interacting with Remote Config.
public protocol RemoteConfigType {

    /// The settings for the Remote Config instance.
    var configSettings: RemoteConfigSettings { get set }

    /// Fetches the latest remote configuration.
    /// - Parameter completionHandler: A closure that is called with the fetch status and an optional error upon completion.
    func fetch(completionHandler: ((RemoteConfigFetchStatus, Error?) -> Void)?)

    /// Activates the fetched remote configuration.
    /// - Parameter completion: A closure that is called with a flag indicating if the configuration was activated and an optional error.
    func activate(completion: ((Bool, Error?) -> Void)?)

    /// Retrieves the configuration value for the specified key.
    /// - Parameter key: The key for which the config value is needed.
    /// - Returns: The `RemoteConfigValue` associated with the key.
    func configValue(forKey key: String?) -> RemoteConfigValue

    /// Adds a listener for configuration updates.
    /// - Parameter listener: A closure that is called when a configuration update occurs, with an optional error.
    /// - Returns: A registration object for the config update listener.
    func addOnConfigUpdateListener(remoteConfigUpdateCompletion listener: @escaping (RemoteConfigUpdate?, Error?) -> Void) -> ConfigUpdateListenerRegistration

    /// Sets the default values from the specified plist file.
    /// - Parameter fileName: The name of the plist file containing default config values.
    func setDefaults(fromPlist fileName: String?)

    /// Retrieves all the keys from the specified source.
    /// - Parameter source: The source from which to retrieve the keys.
    /// - Returns: An array of strings representing the keys.
    func allKeys(from source: RemoteConfigSource) -> [String]

    /// Fetches the latest configuration and activates it if successful.
    /// - Parameter completionHandler: A closure that is called with the fetch and activate status and an optional error.
    func fetchAndActivate(completionHandler: ((RemoteConfigFetchAndActivateStatus, Error?) -> Void)?)

}
