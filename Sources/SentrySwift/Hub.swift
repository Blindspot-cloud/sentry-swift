//
//  Hub.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation


public class Hub {
    @TaskLocal internal static var hub = Hub(scope: Scope())
    
    public static func current() -> Hub {
        hub
    }
    
    public static func run<R>(with: Hub, operation: () throws -> R) rethrows -> R {
        return try $hub.withValue(with, operation: operation)
    }

    public static func run<R>(with: Hub, operation: () async throws -> R) async rethrows -> R {
        return try await $hub.withValue(with, operation: operation)
    }
    
    public static func new_from_top(other: Hub) -> Hub {
        return Hub(client: other.client, scope: other.scopes.last ?? Scope())
    }
    
    public init(client: Client? = nil, scope: Scope) {
        self.client = client
        self.scopes = [scope]
    }
    
    internal var client: Client?
    internal var scopes: [Scope]
    
    public func push_scope() {
        scopes.append(scopes.last ?? Scope())
    }
    
    public func pop_scope() {
        let _ = scopes.popLast()
    }
    
    public func bind_client(client: Client?) {
        self.client = client
    }
    
    public func start_transaction(name: String, op: OperationType, headers: [String: String]? = nil) -> Transaction {
        return Transaction(name: name, op: op, headers: headers)
    }
    
    public func configure_scope<D>(_ cb: (inout Scope) -> D) -> D? {
        guard Sentry.instance.options.disabled == false else {
            return nil
        }
        
        var scope = scopes.last!
        return cb(&scope)
    }
    
    public func add_breadcrumb(_ bc: Breadcrumb) {
        var scope = scopes.last!
        scope.add_breadcrumb(bc)
    }
    
    public func capture_error(error: Error) {
        guard Sentry.instance.options.disabled == false else {
            return
        }
        
        if let client = self.client {
            let ex = ExceptionDataBag(
                type: error.localizedDescription, value: nil, stacktrace: nil)
            let exs = Exceptions(values: [ex])
            
            client.capture_event(event: Event(event_id: UUID(), timestamp: Date().timeIntervalSince1970, level: .error, logger: nil, transaction: nil, server_name: nil, release: nil, dist: nil, tags: nil, environment: nil, modules: nil, extra: nil, message: nil, exception: exs, breadcrumbs: nil, user: nil, request: nil, sdk: nil, contexts: nil, type: nil, spans: nil, start_timestamp: nil, transaction_info: nil), scope: scopes.last)
        }
    }
    
    
    public func capture_event(event: Event) {
        guard Sentry.instance.options.disabled == false else {
            return
        }
        
        if let client = self.client {
            client.capture_event(event: event, scope: scopes.last)
        }
    }
}
