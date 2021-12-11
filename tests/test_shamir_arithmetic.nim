
import unittest

import keyxn/shamir_arithmetic

test "can add":
  check add(5, 5) == 10


test "pfield add"

  assert Arithmetic.+(16,16) == 0
  assert Arithmetic.+(3,4) == 7
  # assert Arithmetic.+(3,4) == 7

test "pfield mult":
  assert Arithmetic.*(3,7) == 9
  assert Arithmetic.*(3,0) == 0
  assert Arithmetic.*(0,3) == 0

test "pfield div":
  assert Arithmetic./(0,7) == 0
  assert Arithmetic./(3,3) == 1
  assert Arithmetic./(6,3) == 2

test "random polynomial? ":
  poly = Arithmetic.polynomial(42, 2)

  assert [42 | res] = poly
  assert length(res) == 2

test "poly evaluate simple":

  poly = Arithmetic.polynomial(42, 1)

  assert Arithmetic.evaluate(poly, 0) == 42

test "poly evaluate advanced":

  poly = Arithmetic.polynomial(42, 1)

  res_poly = Arithmetic.evaluate(poly, 1)
  res_exp = Arithmetic.+(42, Arithmetic.*(1, Enum.at(poly,1) ))

  assert res_poly == res_exp

test "poly random":

  for i <- 0..255:

    poly = Arithmetic.polynomial(i,2)

    x_vals = [1, 2, 3]
    y_vals = x_vals |> Enum.map(&(Arithmetic.evaluate(poly, &1)))

    out = Arithmetic.interpolate(x_vals, y_vals, 0)

    assert out == i
