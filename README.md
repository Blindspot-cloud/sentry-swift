
# Sentry Swift

This is a WIP implementation of Sentry SDK in native swift using swift async/await concurrency.

## Why

Currently there are none swift native implementation of Sentry SDK (only https://github.com/swift-sentry/swift-sentry, which is far from complete and without async await support). Another reason is a need of Sentry tracing and logging for [Vapor](https://vapor.codes/) projects.

## Usage


```swift

let dsn = try Dsn(fromString: "SENTRY_DSN")

// initialization of sentry returns a closing guard that is used to close sentry connection
let sentryGuard = try Sentry.initialize(dsn: dsn)

Sentry.configure_scope {
    $0.set_tag(key: "foo", val: "bar")
}

let event = Event(event_id: UUID(), timestamp: Date().timeIntervalSince1970, level: nil, logger: nil, transaction: nil, server_name: nil, release: nil, dist: nil, tags: nil, environment: nil, modules: nil, extra: nil, message: nil, exception: nil, breadcrumbs: nil, user: nil, request: nil, sdk: nil, contexts: nil, type: nil, spans: nil, start_timestamp: nil, transaction_info: nil)
        
Sentry.capture_event(event: event)

let transaction = Sentry.start_transaction(name: "GET /foo", op: .http_server)
        tr.set_name_source(.route)

// ...
// Do some work
// ...                                   
     
transaction.finish()


// when we are done with sentry we simple close the connection
try await sentryGuard.close()

```
                                                                
## Sentry options

`SentryOptions` that can be passed into `Sentry.initialize` takes many arguments to customize behaviour of the SDK or to add meta data to tracked events like release name.

| option             | value                                      | description                                              |
|--------------------|--------------------------------------------|----------------------------------------------------------|
| release            | String?                                    | Release name                                             |
| environment        | String (default production)                | Environment name                                         |
| server_name        | String?                                    | Server name                                              |
| debug              | Bool (default false)                       | Enable debug (prints debug information)                  |
| disabled           | Bool (default false)                       | Disables sentry SDK                                      |
| sample_rate        | Float (1.0 >= sample_rate >= 0.0)          | Tells sentry SDK how many events should be sampled       |
| traces_sample_rate | Float (1.0 >= traces_sample_rate >= 0.0)   | Tells sentry SDK how it should sample transaction events |
| transport_factory  | TransportFactory (default AsyncHTTPClient) | Factory that creates a new transporter                   |
