import std/sysrand
import strutils
import sequtils

import tables

type
  gfInt8* = distinct uint8
  Polynomial* = object
    coefs*: seq[gfInt8]

proc log*(x: gfInt8): gfInt8 {.inline.} =
  result = gfint8 tables.log_over_log_table[x.uint8]

proc exp*(x: gfInt8): gfint8 {.inline.} =
  result = gfint8 tables.anti_log_table[x.uint8]

proc `+`*(x, y: gfInt8): gfInt8 =
  var val: int = x.int + y.int 
  result = gfInt8(val mod 255)

proc `-`*(x, y: gfInt8): gfInt8 =
  var val: int = x.int - y.int
  result = gfInt8((val + 255) mod 255)

proc `==`*(x, y: gfInt8): bool {.borrow.}

proc `'g8`*(n: string): gfInt8 =
  # The leading ' is required.
  result = (parseInt(n) and 0xFF).gfInt8()

proc `div`*(lhs, rhs: gfint8): gfint8 =
  var
    zero: gfInt8 = 0'g8
    ret: gfInt8 = exp(log(lhs) - log(rhs))
  # done for timing purposes
  if lhs == 0'g8: zero else: ret

# Multiplies two numbers in GF(2^8)
proc `*`*(lhs, rhs: gfInt8): gfInt8 =
  var
    zero = 0'g8
    ret = exp(log(lhs) + log(rhs))

  # done for timing purposes
  if lhs == 0'g8 or rhs == 0'g8: zero else: ret

proc randPolynomial*(intercept: gfInt8, degree: int): Polynomial =
  result.coefs = newSeq[gfInt8](degree+1)
  result.coefs[1..^1] = urandom(degree).mapIt(it.gfInt8()) 

proc evaluate*(poly: Polynomial, x: gfInt8): gfInt8 =
  ## evaluate the GF polynomial for a given set of X's and Y's
  if x == 0'g8:
    result = poly.coefs[0]
  else:
    # Use Horner's method:
    #  essentially multiply `x` by itself `n` times while adding each
    #  lower order coefficient as the 'intercept' each time 
    #  ... or something ;)
    let n = poly.coefs.high - 1
    result = poly.coefs[^1]
    for i in countdown(n, 0):
      result = result * x + poly.coefs[i]

proc `[]`*(poly: Polynomial, x: gfInt8): gfInt8 =
  result = poly.evaluate(x)

proc interpolate*(x_samples, y_samples: seq[gfInt8], x: gfInt8): gfInt8 =
  ## interpolate the GF polynomial for a given set of X's and Y's
  
  # Setup interpolation env
  assert x_samples.len() == y_samples.len()
  var limit = len(x_samples) - 1

  # Loop through all the x & y samples, reducing them to an answer
  for i in 0..limit:
    var basis = 1'g8
    for j in 0..limit:
      if i == j:
        continue
      basis = basis * (x + x_samples[j]) div (x_samples[i] + x_samples[j])

    let group = basis * y_samples[i]
    result = result + group

