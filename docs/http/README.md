The http package is a simple, low level library optimized for our specific usecase (ie. JSON messages over HTTP).

From one ghci instance, fire up a server:
```
> ghci http.hs
*Main> :set -XOverloadedStrings
*Main> let wrapper path dat = return $ object ["wrappedForYou" .= dat]
*Main> serve 6655 wrapper
```

From an other one, make a request:
```
> ghci http.hs
*Main> :set -XOverloadedStrings
*Main> req "http://127.0.0.1:6655" $ object ["a" .= 12]
Just (Object fromList [("wrappedForYou",Object fromList [("a",Number 12.0)])])
```

We can also curl our server:

```
curl http://127.0.0.1:6655/ -d '{"a":"b"}'
```