# Shamir Secret in pure Nim

This is a port from the [KeyX](https://github.com/elcritch/keyx) which is itself a re-implementation of Hashicorp's Shamir in Go.

Usage is simple. 

```nim
```

## History

The primary reason for matching the Hashicorp version is to match a widely known and used Shamir Secret Sharing implementation.

In particular this version uses an array of N independent bytes evaluated at a random X which is appended to the end of each share. This means only a single Finite Arithmetic field is used, namely 255.   