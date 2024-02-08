import XCTest
@testable import SentrySwift


final class sentry_swiftTests: XCTestCase {
    func testExample() async throws {
        let dsn = try Dsn(
        fromString: "https://19f890c7ea3b49048ddcba4aafd79cd3@sentry.bspot.lab.prz/9"
        )
        let sentryGuard = try Sentry.initialize(dsn: dsn, options: .init(debug: true))
        
        assert(Hub.current().client != nil)
        
        
        let tr = Sentry.start_transaction(name: "GET /bar", op: .http_server)
        tr.set_request(Request(method: "GET", url: "/bar"))
        
        try await Task.sleep(nanoseconds: 1000000000)
        
        var span = tr.start_child(op: .http_client, description: "client request")
        try await Task.sleep(nanoseconds: 1000000000)
        span.finish()
        
        tr.set_status(.ok)
        tr.finish()
        
        try await sentryGuard.close()
    }
}
