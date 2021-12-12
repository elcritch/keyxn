# Shamir Secret Sharing (in pure Nim!)

Easily create N cryptographically secure shares of a secret, with only K parts required to recover the secret (K <= N). 

This can be a fun way to share a secret among N people and allow any K of them to recover the secret. Or perhaps allow your family to recover your crypto-wallet if an untimely demise should befall you. 

This is a port of [KeyX](https://github.com/elcritch/keyx) which is itself a re-implementation of Hashicorp's Shamir in Go.

Usage is simple: 

```nim
import keyxn
# Create a secret
let secret: ShamirSecret = initSecret("super secret")
# Split into 4 parts and require 2 to recover
let shares: seq[ShamirShare] = secret.split(k=2, parts=4)

# Recover secret with 2 parts
let recovered = shares[0..1].recover()

assert secret == recovered
```

The secrets and shares are displayed/serialized as hex strings. There are convenience procs for parsing directly from a hex string:

```nim
import keyxn
let someSecret = parseSecretHex("super secret".toHex())
let aShare: ShamirShare = parseShareHex("C8EF4C4201")
```

## History

The primary reason for matching the Hashicorp version is to match a widely known and used Shamir Secret Sharing implementation.

In particular this version uses a separate Shamir polynomial for each byte, but using a single intercept for each secret-share. This results in an array of N independent Y-values each a byte in size. Each share has it's selected X value appended to the end of that share. In general, this sheme means only a single Finite Arithmetic field needs to be used, namely GF(255).
