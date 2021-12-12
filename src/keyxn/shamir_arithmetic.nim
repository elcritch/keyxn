import std/sysrand
import strutils

import tables

type
  gfInt8* = distinct uint8
  Polynomial* = object
    coefs*: seq[gfInt8]

proc `$`*(x: gfInt8): string {.borrow.}

proc log*(x: gfInt8): gfInt8 {.inline.} =
  result = gfint8 tables.log_over_log_table[x.uint8]

proc exp*(x: gfInt8): gfint8 {.inline.} =
  result = gfint8 tables.anti_log_table[x.uint8]

proc `+`*(x, y: gfInt8): gfInt8 =
  result = gfInt8(x.uint8 xor y.uint8) 

proc `-`*(x, y: gfInt8): gfInt8 {.borrow.}
proc `==`*(x, y: gfInt8): bool {.borrow.}

proc `'g8`*(n: string): gfInt8 =
  # The leading ' is required.
  result = (parseInt(n) and 0xFF).gfInt8()

proc `div`*(lhs, rhs: gfint8): gfint8 =
  var
    zero: gfInt8 = 0'g8
    sub = log(lhs).int - log(rhs).int + 255
    ret: gfInt8 = exp(gfInt8( sub mod 255))
  # done for timing purposes
  if lhs == 0'g8: zero else: ret

# Multiplies two numbers in GF(2^8)
proc `*`*(lhs, rhs: gfInt8): gfInt8 =
  var
    zero = 0'g8
    sum = log(lhs).int + log(rhs).int
    ret = exp(gfInt8(sum mod 255))

  # done for timing purposes
  if lhs == 0'g8 or rhs == 0'g8: zero else: ret

proc randPolynomial*(intercept: gfInt8, degree: uint): Polynomial =
  result.coefs = newSeq[gfInt8](degree+1)
  result.coefs[0] = intercept
  if degree > 1:
    let rd = urandom(degree)
    for i in 1..<len(result.coefs):
      result.coefs[i] = gfInt8 rd[i-1]

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

proc interpolate*(xs, ys: seq[gfInt8], x: gfInt8): gfInt8 =
  ## interpolate the GF polynomial for a given set of X's and Y's
  
  # Setup interpolation env
  assert xs.len() == ys.len()

  # Loop through all the x & y samples, reducing them to an answer
  var val = 0'g8
  for i in 0..<len(xs):
    var ba = 1'g8
    for j in 0..<len(ys):
      if i == j: continue
      ba = ba * (x + xs[j]) div (xs[i] + xs[j])

    let group = ys[i] * ba
    val = val + group
  result = val