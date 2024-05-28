import Leaf
import Vapor

/// A better way to organize your routes.
public struct Ziggy {
    fileprivate let application: Application

    /// Configure the Ziggy package.
    /// This method should be called in `configure.swift`.
    public func setup() {
        application.leaf.tags["routes"] = ZiggyTag(ziggy: self)
    }

    /// Build a URL for the given route and parameters.
    ///
    ///    ziggy.route("users.edit", params: [user.id]) // "/users/1/edit"
    ///
    /// - Parameters:
    ///  - name: The name of the route
    ///  - params: The parameters to pass to the route
    public func route(_ name: String, params: [String]) -> String? {
        var params = params

        guard let route: Vapor.Route = routes()[name] else {
            return nil
        }

        let uri = route.path.map { component in
            switch component {
                case let .constant(path):
                    return path
                case .parameter, .anything:
                    return params.removeFirst()
                case .catchall:
                    return params.joined(separator: "/")
            }
        }.joined(separator: "/")

        return "/" + uri
    }

    private func routes() -> [String: Route] {
        return application.routes.all
            .filter { $0.userInfo["name"] != nil }
            .map { ($0.userInfo["name"] as! String, Route($0)) }
            .reduce(into: [String: Route]()) { routes, route in
                if routes[route.0] == nil {
                    routes[route.0] = route.1
                } else {
                    if routes[route.0]!.uri == route.1.uri {
                        routes[route.0]!.methods.append(contentsOf: route.1.methods.filter { !routes[route.0]!.methods.contains($0) })
                    } else {
                        routes[route.0] = route.1
                    }
                }
            }
    }

    /// Get a dictionary of all named routes in the application.
    public func routes() -> [String: Vapor.Route] {
        application.routes.all
            .filter { $0.userInfo["name"] != nil }
            .reduce(into: [String: Vapor.Route]()) { routes, route in
                routes[route.userInfo["name"] as! String] = route
            }
    }

    private func serialize(url: URL) -> String {
        let data = try! JSONEncoder().encode(Serialized(url: url.absoluteString, port: url.port, routes: routes(), defaults: [:]))

        return String(data: data, encoding: .utf8)!
    }

    private struct Serialized: Content {
        var url: String?
        var port: Int?
        var routes: [String: Route]
        var defaults: [String: String]
    }

    private struct Route: Content {
        /// The URI of the route.
        var uri: String
        /// The HTTP methods of the route.
        var methods: [String]
        /// The parameters of the route.
        var parameters: [String]?
        /// The where constraints of the route.
        var wheres: [String: String]?

        fileprivate init(_ route: Vapor.Route) {
            uri = route.path.map { component in
                switch component {
                    case let .constant(path):
                        return path
                    case let .parameter(parameter):
                        return "{\(parameter)}"
                    case .anything:
                        return "{wildcard}"
                    case .catchall:
                        return "{fallbackPlaceholder}"
                }
            }.joined(separator: "/")

            parameters = route.path.compactMap { component in
                switch component {
                    case .constant:
                        return nil
                    case let .parameter(parameter):
                        return parameter
                    case .anything:
                        return "wildcard"
                    case .catchall:
                        return "fallbackPlaceholder"
                }
            }

            methods = [route.method.string]
            wheres = route.path.filter { $0 == .catchall }.isEmpty ? nil : ["fallbackPlaceholder": ".*"]
        }
    }

    struct ZiggyTag: UnsafeUnescapedLeafTag {
        let ziggy: Ziggy

        struct ZiggyError: Error, DebuggableError {
            var identifier: String { "ZiggyError" }
            var reason: String { "Ziggy requires a request to be present when rendering your views." }
            var suggestedFixes: [String] { ["Make sure you're rendering your views from the request object, not the application object."] }
        }

        func render(_ ctx: LeafContext) throws -> LeafData {
            guard let req = ctx.request else {
                throw ZiggyError()
            }

            let ziggy = ziggy.serialize(url: req.baseURL!)

            return LeafData.string("<script type=\"text/javascript\">const Ziggy=\(ziggy);</script>")
        }
    }
}

public extension Route {
    /// Name the route.
    /// - Parameters
    ///   - name: The name of the route
    @discardableResult
    func name(_ name: String) -> Route {
        userInfo["name"] = name
        return self
    }
}

public extension Application {
    /// Access the Ziggy package.
    var ziggy: Ziggy {
        .init(application: self)
    }

    /// Build a URL for the given route and parameters.
    ///
    ///    app.route("users.edit", user.id) // "/users/1/edit"
    ///
    /// - Parameters:
    ///  - name: The name of the route
    ///  - params: The parameters to pass to the route
    func route(_ name: String, _ params: String...) -> String? {
        ziggy.route(name, params: params)
    }
}

public extension Request {
    /// Build a URL for the given route and parameters.
    ///
    ///    req.route("users.edit", user.id) // "/users/1/edit"
    ///
    /// - Parameters:
    ///  - name: The name of the route
    ///  - params: The parameters to pass to the route
    func route(_ name: String, _ params: String...) -> String? {
        application.ziggy.route(name, params: params)
    }

    /// Creates a redirect `Response` to a named route.
    ///
    ///     router.get("redirect") { req in
    ///         return req.redirect(route: "dashboard")
    ///     }
    ///
    /// Set type to '.permanently' to allow caching to automatically redirect from browsers.
    /// Defaulting to non-permanent to prevent unexpected caching.
    /// - Parameters:
    ///   - route: The named route to redirect to
    ///   - parameters: The parameters to pass to the route
    ///   - redirectType: The type of redirect to perform
    /// - Returns: A response that redirects the client to the specified location
    func redirect(route: String, _ parameters: String..., redirectType: Redirect = .normal) -> Response {
        let url = application.ziggy.route(route, params: parameters) ?? route

        return redirect(to: url, redirectType: redirectType)
    }
}
