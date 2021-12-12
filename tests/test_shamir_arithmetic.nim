
import unittest

import keyxn/shamir_arithmetic

test "can add":
  check add(5, 5) == 10


test "pfield add":
  check Arithmetic.+(16,16) == 0
  check Arithmetic.+(3,4) == 7
  # check Arithmetic.+(3,4) == 7

test "pfield mult":
  check Arithmetic.*(3,7) == 9
  check Arithmetic.*(3,0) == 0
  check Arithmetic.*(0,3) == 0

test "pfield div":
  check Arithmetic./(0,7) == 0
  check Arithmetic./(3,3) == 1
  check Arithmetic./(6,3) == 2

test "random polynomial? ":
  poly = Arithmetic.polynomial(42, 2)

  check [42 | res] = poly
  check length(res) == 2

test "poly evaluate simple":

  poly = Arithmetic.polynomial(42, 1)

  check Arithmetic.evaluate(poly, 0) == 42

test "poly evaluate advanced":

  poly = Arithmetic.polynomial(42, 1)

  res_poly = Arithmetic.evaluate(poly, 1)
  res_exp = Arithmetic.+(42, Arithmetic.*(1, Enum.at(poly,1) ))

  check res_poly == res_exp

test "poly random":

  for i <- 0..255:

    poly = Arithmetic.polynomial(i,2)

    x_vals = [1, 2, 3]
    y_vals = x_vals |> Enum.map(&(Arithmetic.evaluate(poly, &1)))

    out = Arithmetic.interpolate(x_vals, y_vals, 0)

    check out == i
