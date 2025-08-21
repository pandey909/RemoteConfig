//
//  RemoteConfigManagerType.swift
//
//
//  Created by Chiragdip Israni on 27/03/25.
//

import Foundation

public protocol RemoteConfigManagerType {

    /// Fetches and returns a string value for the specified key.
    /// - Parameter key: The key to retrieve the value for.
    /// - Returns: The string value, or `nil` if not found or an error occurs.
    func getValue(forKey key: RemoteConfigKey) -> String?

    /// Fetches and returns a double value for the specified key.
    /// - Parameter key: The key to retrieve the value for.
    /// - Returns: The double value, or `nil` if not found or an error occurs.
    func getValue(forKey key: RemoteConfigKey) -> Double?

    /// Fetches and returns a Int value for the specified key.
    /// - Parameter key: The key to retrieve the value for.
    /// - Returns: The Int value, or `nil` if not found or an error occurs.
    func getValue(forKey key: RemoteConfigKey) -> Int?

    /// Fetches and returns a boolean value for the specified key.
    /// - Parameter key: The key to retrieve the value for.
    /// - Returns: The boolean value, or `nil` if not found or an error occurs.
    func getValue(forKey key: RemoteConfigKey) -> Bool? // swiftlint:disable:this discouraged_optional_boolean

    /// Fetches and returns an array value for the specified key.
    /// - Parameter key: The key to retrieve the value for.
    /// - Returns: The array value, or `nil` if not found or an error occurs.
    func getValue(forKey key: RemoteConfigKey) -> [Any]?

    /// Fetches and returns a dictionary value for the specified key.
    /// - Parameter key: The key to retrieve the value for.
    /// - Returns: The dictionary value, or `nil` if not found or an error occurs.
    func getValue(forKey key: RemoteConfigKey) -> [String: Any]?

}
