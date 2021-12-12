
import unittest
import sequtils

import keyxn/gf_arithmetic

test "pfield add":
  check 16'g8 + 16'g8 == 0'g8
  check 3'g8 + 4'g8 == 7'g8

test "pfield mult":
  check 3'g8 * 7'g8 == 9'g8
  check 3'g8 * 0'g8 == 0'g8
  check 0'g8 * 3'g8 == 0'g8

test "pfield div":
  check 0'g8 div 7'g8 == 0'g8
  check 3'g8 div 3'g8 == 1'g8
  check 6'g8 div 3'g8 == 2'g8

test "random polynomial? ":
  let poly = randPolynomial(42'g8, 2)

  check 42'g8 == poly.coefs[0]
  check poly.coefs.len() == 3

test "poly evaluate simple":

  let poly = randPolynomial(42'g8, 1)

  check evaluate(poly, 0'g8) == 42'g8

test "poly evaluate advanced":

  let poly = randPolynomial(42'g8, 1)

  let res_poly = evaluate(poly, 1'g8)
  let res_poly2 = poly[1'g8]
  let res_exp = 42'g8 + 1'g8 * poly.coefs[1]

  check res_poly == res_exp
  check res_poly2 == res_exp

test "poly random":

  for i in 0..255:

    let val = i.gfInt8()
    let poly = randPolynomial(val, 2)

    let x_vals = @[1'g8, 2'g8, 3'g8]
    let y_vals = x_vals.mapIt(poly.evaluate(it)) 

    let res = interpolate(x_vals, y_vals, 0'g8)
    check res == val
