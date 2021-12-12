import random
import sets
import sequtils
import strutils

import gf_arithmetic

type
  ShamirSecret* = object
    data*: string
  ShamirPart* = object
    data*: string

proc `$`*(shs: ShamirSecret): string =
  result = shs.data.toHex()

proc parseSecretHex*(hexValue: string): ShamirSecret =
  result = ShamirSecret(data: hexValue.parseHexStr())
proc initSecret*(rawValue: string): ShamirSecret =
  result = ShamirSecret(data: rawValue)

proc parseShareHex*(hexValue: string): ShamirPart =
  result = ShamirPart(data: hexValue.parseHexStr())
proc initShare*(rawValue: string): ShamirPart =
  result = ShamirPart(data: rawValue)

# @spec split_secret(non_neg_integer, non_neg_integer, binary) :: list(binary)
proc split*(secret: ShamirSecret, k, parts: uint): seq[ShamirPart] =
  if parts > 255:
    raise newException(ValueError, "too many parts, n <= 255")
  elif k > parts:
    raise newException(ValueError, "k cannot be less than total shares")
  elif k < 2:
    raise newException(ValueError, "k cannot be less than 2")
  elif secret.data.len() == 0:
    raise newException(ValueError, "secret cannot be zero")

  # randomize
  var x_cords = newSeq[byte](255)
  for i in 0..<255: x_cords[i] = i.byte

  var r = initRand()
  r.shuffle(x_cords)

  # This is where implementations can differ, presumably.
  # The H.C. Vault developers noted:
  # Make random polynomials for each byte of the secret
  # Construct a random polynomial for each byte of the secret.
  #	Because we are using a field of size 256, we can only represent
  #	a single byte as the intercept of the polynomial, so we must
  #	use a new polynomial for each byte.
  # We could use larger numbers (large field set (larger primes?)),
  # but maintaining compatibility is a key goal in this project
  var shares: seq[ShamirPart]
  newSeq(shares, parts)
  for idx in 0..<parts:
    shares[idx].data = newString(secret.data.len()+1)
    shares[idx].data[^1] = char(x_cords[idx] + 1)

  for idx, val in secret.data:
    let poly = randPolynomial(val.gfInt8(), k-1)

    for j in 0..<parts:
      let x = gfInt8(x_cords[j] + 1)
      let y = poly.evaluate(x)
      shares[j].data[idx] = y.char

  return shares

proc recover*(shares: openArray[ShamirPart]): ShamirSecret =
  # Constants
  if shares.len() < 1:
    raise newException(ValueError, "not enough shares")

  let y_len = shares[0].data.len() - 1
  for share in shares:
    if share.data.len() - 1 != y_len:
      raise newException(ValueError, "share must be same size")

  # Error checking
  let shashes = toHashSet(shares)
  if shashes.len() != shares.len():
    raise newException(ValueError, "Duplicated shares")

  # Evaluate polynomials and return secret!
  let x_samples = shares.mapIt(it.data[^1].gfInt8())
  var secret = ShamirSecret(data: newString(y_len))
  for idx in 0..<y_len:
    let y_samples = shares.mapIt(it.data[idx].gfInt8())
    secret.data[idx] = interpolate(x_samples, y_samples, 0'g8).char()

  return secret
