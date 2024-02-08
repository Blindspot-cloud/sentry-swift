//
//  SentryLoggerIntegration.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation
import Logging


public struct SentryLoggerIntegration: LogHandler {
    private let label: String
    public var metadata: Logging.Logger.Metadata = Logger.Metadata()
    
    public var logLevel: Logging.Logger.Level

    public init(label: String, logLevel: Logging.Logger.Level) {
        self.label = label
        self.logLevel = logLevel
    }

    public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        if level == .error {
            let frame = Frame(filename: file, function: function, raw_function: nil, lineno: Int(line), colno: nil, abs_path: nil, instruction_addr: nil)
            let stacktrace = Stacktrace(frames: [frame])
            
            let exp = Exceptions(values: [ExceptionDataBag(type: message.description, value: nil, stacktrace: stacktrace)])
            
            let metadataEscaped = (metadata ?? [:])
                .merging(self.metadata, uniquingKeysWith: { a, _ in a })
                .merging(self.metadataProvider?.get() ?? [:], uniquingKeysWith: { (a, _) in a })
            
            let tags = metadataEscaped.mapValues { "\($0)" }
            
            let event = Event(event_id: UUID(), timestamp: Date().timeIntervalSince1970, level: Level(from: level), logger: label, transaction: metadataEscaped["transaction"]?.description, server_name: nil, release: nil, dist: nil, tags: tags.isEmpty ? nil : tags, environment: nil, modules: nil, extra: nil, message: nil, exception: exp, breadcrumbs: nil, user: nil, request: nil, sdk: nil, contexts: nil, type: nil, spans: nil, start_timestamp: nil, transaction_info: nil)
            
            Sentry.capture_event(event: event)
        } else if level >= .info {
            Hub.current().add_breadcrumb(Breadcrumb(message: message.description, timestamp: Date().timeIntervalSince1970, category: "log"))
        }
    }    
}
