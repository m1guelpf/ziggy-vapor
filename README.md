# Ziggy for Vapor

> A better way to organize your routes.

[![Swift Version](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fm1guelpf%2Fziggy-vapor%2Fbadge%3Ftype%3Dswift-versions&color=brightgreen)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-4-30B6FC.svg)](http://vapor.codes)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/m1guelpf/ziggy-vapor/main/LICENSE)

# Installation

Add `Ziggy` to the package dependencies (in your `Package.swift` file):

```swift
dependencies: [
    ...,
    .package(url: "https://github.com/m1guelpf/ziggy-vapor.git", from: "1.0.0")
]
```

as well as to your target (e.g. "App"):

```swift
targets: [
    ...
    .target(
        name: "App",
        dependencies: [... "Ziggy" ...]
    ),
    ...
]
```

## Getting started 🚀

Import Ziggy in your `configure.swift` file, then call the `setup` method:

```swift
// Sources/App/configure.swift
import Ziggy

// configures your application
public func configure(_ app: Application) async throws {
    // ...

    app.ziggy.setup()

    // ...
}
```

Then, on your `routes.swift` file (or wherever you define your routes), you can chain the `name` method to your routes to give them a name:

```swift
// Sources/App/routes.swift
import Vapor
import Ziggy

public func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("dashboard")
    }.name("dashboard")

    // ...
}
```

You can then use the `app.route` (or `req.route`) function to generate URLs for your routes:

```swift
let url = app.route("home") // /dashboard
let edit_user = req.route("users.edit", 1) // /users/1/edit

return req.redirect(route: "user.profile", "m1guelpf") // Redirects to /@m1guelpf
```

You can also access the `route` function on your frontend, by adding the `routes` tag to your HTML template and installing [the `ziggy-js` package](https://www.npmjs.com/package/ziggy-js):

```leaf
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8">
        <link rel="stylesheet" href="/app.css" />
        <script type="module" src="/app.js"></script>

		#routes()
	</head>

	<body>
		<!-- ... -->
	</body>
</html>
```

## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
