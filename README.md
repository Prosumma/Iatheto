Iatheto
==

Iatheto is a minimal JSON framework that serializes to and from Apple's `Codable`. By now there are many such frameworks, but Iatheto is one of the oldest — it predates `Codable` — with a very tiny implementation.

Iatheto supports only those types directly supported by JSON and no others. To handle a date, for instance, you must first turn it into a string.

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
