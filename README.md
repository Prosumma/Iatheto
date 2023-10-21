Iatheto
==

Iatheto is a minimal JSON framework that serializes to and from Apple's `Codable`. By now there are many such frameworks, but Iatheto is one of the oldest — it predates `Codable` — with a very tiny implementation.

Iatheto supports only those types directly supported by JSON and no others. To handle a date, for instance, you must first turn it into a string.

Literals
--

Like most modern Swift JSON frameworks, Iatheto supports the usual literal assignments:

```swift
var json: JSON = nil // Produces JSON.null
json = "json" // Produces JSON.string("json")
json = ["array": [1, 2, 3]] // Produces JSON.object(["array": JSON.array([1, 2, 3])])
```

Attributes
--

Iatheto has nilable properties &mdash; getters and setters &mdash; which can be used to get typed values.

```swift
let json: JSON = "json"
let s = json.string // If json is JSON.string, then s will be "json", otherwise nil. 
```

Assigning `nil` to one of these properties changes the receiver to `JSON.null`:

```swift
var json: JSON = "json"
json.string = nil // json is now JSON.null
```

Subscripts
--

Iatheto has exactly the subscripts you'd expect:

```swift
let json: JSON = ["foo": ["bar"]]
let s = json["foo"]?[0]?.string // If the types work out s will be "bar", otherwise nil.
```

Assignment through the subscripts is possible. Assigning `nil` to an array subscript produces `JSON.null`. However, assigning `nil` through an object subscript removes the entry from the underlying object. To specifically set to `JSON.null`, assign that
particular value.

```swift
var json: JSON = ["foo": ["bar"]]
json["foo"]?[0] = nil // Produces {"foo": [null]}
json["foo"] = .null // Produces {"foo": null}
json["foo"] = nil // Produces {}
```

During a subscript assignment, if the underlying value is not an array or object, it becomes one:

```swift
var json: JSON = nil
json["foo"] = "bar" // Produces {"foo": "bar"}
json["foo"]?.int = 3 // Produces {"foo": 3}
```

Encoding
--

Iatheto's `JSON` type supports initialization by many kinds of literals, so the syntax is natural.

```swift
let json: JSON = ["first_name": "Murray", "last_name": "Rothbard", "born": 1926, "died": 1995]
let encoder = JSONEncoder()
let data = try encoder.encode(json)
```

Decoding
--

Decoding is as straightforward as encoding:

```swift
let decoder = JSONDecoder()
let json = try decoder.decode(JSON.self, from: data)
```

What's a Iatheto?
--

"Iatheto" comes from the Greek ἰαθήτω, "she shall be healed", which in turn comes the verb  ἰάομαι "to heal". This verb is the origin of the name Ἰάσων "Jason".
