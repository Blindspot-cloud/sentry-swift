
# Sentry Swift

This is a WIP implementation of Sentry SDK in swift.

## Usage


```swift

let dsn = try Dsn(fromString: "http://ba3bd47ce2ec3f5ee5a8bb17797a30ba@localhost:3000/13")

// initialization of sentry returns a closing guard that is used to close sentry connection
let sentryGuard = try Sentry.initialize(dsn: dsn)

Sentry.configure_scope {
    $0.set_tag(key: "foo", val: "bar")
}

let event = Event(event_id: UUID(), timestamp: Date().timeIntervalSince1970, level: nil, logger: nil, transaction: nil, server_name: nil, release: nil, dist: nil, tags: nil, environment: nil, modules: nil, extra: nil, message: nil, exception: nil, breadcrumbs: nil, user: nil, request: nil, sdk: nil, contexts: nil, type: nil, spans: nil, start_timestamp: nil, transaction_info: nil)
        
Sentry.capture_event(event: event)

var transaction = Sentry.start_transaction(name: "GET /foo", op: .http_server)
        tr.set_name_source(.route)

// ...
// Do some work
// ...                                   
     
transaction.finish()


// when we are done with sentry we simple close the connection
try await sentryGuard.close()

```
                                                                
                                                                
