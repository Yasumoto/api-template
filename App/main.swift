import Vapor
import VaporZewoMustache

let app = Application()

/**
	This first route will return the welcome.html
	view to any request to the root directory of the website.

	Views referenced with `app.view` are by default assumed
	to live in <workDir>/Resources/Views/ 

	You can override the working directory by passing
	--workDir to the application upon execution.
*/
app.get("/") { request in
	return try app.view("welcome.html")
}

/**
	Return JSON requests easy by wrapping
	any JSON data type (String, Int, Dict, etc)
	in Json() and returning it.

	Types can be made convertible to Json by 
	conforming to JsonRepresentable. The User
	model included in this example demonstrates this.

	By conforming to JsonRepresentable, you can pass
	the data structure into any JSON data as if it
	were a native JSON data type.
*/
app.get("json") { request in
	return Json([
		"number": 123,
		"string": "test",
		"array": [
			0, 1, 2, 3
		],
		"dict": [
			"name": "Vapor",
			"lang": "Swift"
		]
	])
}

/**
	This route shows the various ways to
	access request data. 

	Visit "data/<any-integer>" to view the output.
*/
app.any("data", Int.self) { request, id in
	return Json([
		"request.path": request.path,
		"request.data": "\(request.data)",
		"request.parameters": "\(request.parameters)",
	])
}

/**
	This simple plaintext response is useful
	when benchmarking Vapor.
*/
app.get("plaintext") { request in
	return "Hello, World!"
}

/**
	Vapor automatically handles setting
	and retreiving sessions. Simply add data to
	the session variable and–if the user has cookies
	enabled–the data will persist with each request.
*/
app.get("session") { request in
	let json = Json([
		"session.data": "\(request.session)",
		"request.cookies": "\(request.cookies)",
		"instructions": "Refresh to see cookie and session get set."
	])
	let response = Response(status: .OK, json: json)

	request.session?["name"] = "Vapor"
	response.cookies["test"] = "123"

	return response
}

/**
	Here's an example of using String instead
	of Int to make a type-safe request handler.

	String is the most general and will match any request
	to "posts/<some-string>". To make your data structure
	work with type-safe routing, make it StringInitializable.

	The User model included in this example is StringInitializable.
*/
app.get("posts", String.self) { request, postName in 
	return "Requesting post named \(postName)"
}

/**
	This will set up the appropriate GET, PUT, and POST
	routes for basic CRUD operations. Check out the
	UserController in App/Controllers to see more.
*/
app.resource("users", controller: UserController.self)

/**
	VaporZewoMustache hooks into Vapor's view class to
	allow rendering of Mustache templates. You can 
	even reference included files setup through the provider.
*/
app.get("mustache") { request in
	return try app.view("template.mustache", context: [
		"greeting": "Hello, world!"
	])
}


//Add includeable files to the Mustache provider
VaporZewoMustache.Provider.includeFiles["header"] = "Includes/header.mustache"

/**
	Appending a provider allows it to boot
	and initialize itself as a dependency.
*/
app.providers.append(VaporZewoMustache.Provider)

/**
	Middleware is a great place to filter 
	and modifying incoming requests and outgoing responses. 

	Check out the middleware in App/Middelware.

	You can also add middleware to a single route by
	calling the routes inside of `app.middleware(MiddelwareType) { 
		app.get() { ... }
	}`
*/
app.middleware.append(SampleMiddleware)

// Print what link to visit for default port
print("Visit http://localhost:8080")
app.start(port: 8080)
