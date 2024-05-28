import Vapor

extension Request {
    var isSecure: Bool {
        if let proto = headers.first(name: .xForwardedProto) {
            return ["https", "on", "ssl", "1"].contains(proto)
        }

        return application.http.server.configuration.tlsConfiguration != nil
    }

    var host: String? {
        headers.first(name: .xForwardedHost) ?? headers.first(name: .host)
    }

    var origin: String {
        headers.first(name: .origin) ?? "\(isSecure ? "https" : "http")://\(host!)"
    }

    var baseURL: URL? {
        URL(string: origin)
    }
}
