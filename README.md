# Shamir Secret in pure Nim

This is a port from the [KeyX](https://github.com/elcritch/keyx) which is itself a re-implementation of Hashicorp's Shamir in Go.

Usage is simple. 

```nim
# Create a secret
let secret: ShamirSecret = initSecret("super secret")
# Split into 4 parts and require 2 to recover
let shares: seq[ShamirShare] = secret.split(k=2, parts=4)

# Recover secret with 2 parts
let recovered = shares[0..1].recover()

check secret == recovered
```

## History

The primary reason for matching the Hashicorp version is to match a widely known and used Shamir Secret Sharing implementation.

In particular this version uses an array of N independent bytes evaluated at a random X which is appended to the end of each share. This means only a single Finite Arithmetic field is used, namely 255.   