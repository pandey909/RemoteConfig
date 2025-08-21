//
//  RemoteConfigPublisher.swift
//
//
//  Created by Chiragdip Israni on 27/03/25.
//

import Combine
/// A helper enum to be able to contain publishers with different signatures in a single collection
enum RemoteConfigPublisher {
    case string(CurrentValueSubject<String?, Never>)
    case bool(CurrentValueSubject<Bool?, Never>) // swiftlint:disable:this discouraged_optional_boolean
    case double(CurrentValueSubject<Double?, Never>)
    case array(CurrentValueSubject<[Any]?, Never>)
    case dictionary(CurrentValueSubject<[String: Any]?, Never>)
}
