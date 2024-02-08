//
//  Client.swift
//  
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation
import AsyncHTTPClient
import NIOCore


public class Client {
    private let options: SentryOptions
    
    init(options: SentryOptions) {
        self.options = options
    }
    
    // TODO: Event + Scope
    public func capture_event(event: Event, scope: Scope? = nil) {
        if Sampler.sample(threshhold: options.sample_rate) {
            let envelope: Envelope = .init(
                header: .init(eventId: event.event_id, dsn: nil, sdk: nil),
                items: [
                    .init(
                        header: .init(type: (event.type == .transaction) ? .transaction : .event, filename: nil, contentType: "application/json"),
                        data: enrichEvent(event, scope)
                    ),
                ]
            )
            
            Sentry.instance.transport.send_envelope(envelope: envelope)
        }
    }
    
    private func enrichEvent(_ event: Event, _ scope: Scope?) -> Event {
        let tags = (event.tags ?? [:]).merging(scope?.tags ?? [:]) { (event, _) in event }
        let extra = (event.extra ?? [:]).merging(scope?.extra ?? [:]) { (event, _) in event }
        let contexts = (event.contexts ?? [:]).merging(scope?.contexts ?? [:]) { (event, _) in event }
        
        return Event(event_id: event.event_id, timestamp: event.timestamp, level: event.level ?? scope?.level, logger: event.logger, transaction: event.transaction ?? scope?.transaction, server_name: event.server_name ?? options.server_name, release: event.release ?? options.release, dist: event.dist, tags: tags.isEmpty ? nil : tags, environment: event.environment ?? options.environment, modules: event.modules, extra: extra.isEmpty ? nil : extra, message: event.message, exception: event.exception, breadcrumbs: event.breadcrumbs, user: event.user ?? scope?.user, request: event.request, sdk: event.sdk ?? Sentry.instance.sdk, contexts: contexts, type: event.type, spans: event.spans, start_timestamp: event.start_timestamp, transaction_info: event.transaction_info)
    }
}
