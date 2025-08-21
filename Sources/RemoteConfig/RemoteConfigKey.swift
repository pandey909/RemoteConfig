//
//  RemoteConfigKey.swift
//
//
//  Created by Chiragdip Israni on 27/03/25.
//

import Foundation

public struct RemoteConfigKey: Hashable {
    public let rawValue: String
    
}

/// Extension to group all the feature switches
extension RemoteConfigKey {
    public static let adsConfigDebug = RemoteConfigKey(rawValue: "ADS_CONFIG_DEBUG")
    public static let adsConfigRelease = RemoteConfigKey(rawValue: "ADS_CONFIG_RELEASE")
    
    public static let versionConfigDebug = RemoteConfigKey(rawValue: "VERSION_CONFIG_DEBUG")
    public static let versionConfigRelease = RemoteConfigKey(rawValue: "VERSION_CONFIG_RELEASE")
    
    public static let communityConfigDebug = RemoteConfigKey(rawValue: "COMMUNITY_CONFIG_DEBUG")
    public static let communityConfigRelease = RemoteConfigKey(rawValue: "COMMUNITY_CONFIG_RELEASE")
    
    public static let generalConfigDebug = RemoteConfigKey(rawValue: "GENERAL_CONFIG_DEBUG")
    public static let generalConfigRelease = RemoteConfigKey(rawValue: "GENERAL_CONFIG_RELEASE")
    
    public static let featureEnableConfigDebug = RemoteConfigKey(rawValue: "FEATURE_ENABLE_CONFIG_DEBUG")
    public static let featureEnableConfigRelease = RemoteConfigKey(rawValue: "FEATURE_ENABLE_CONFIG_RELEASE")
    
    public static let communityMetaConfigDebug = RemoteConfigKey(rawValue: "COMMUNITY_META_DEBUG")
    public static let communityMetaConfigRelease = RemoteConfigKey(rawValue: "COMMUNITY_META_RELEASE")
}
