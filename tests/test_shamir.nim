
import unittest
import strutils
import sequtils

import keyxn

test "basic split":
  var secret = ShamirSecret(data: "test")
  var shares = secret.split(3, 5)
  check len(shares) == 5

  for share in shares:
    check len(share.data) == len(secret.data) + 1

test "basic recover static short":
  let shares =
    [ShamirShare(data: "0E4A".parseHexStr()),
     ShamirShare(data: "9954".parseHexStr())]
  let res = shares.recover()
  assert "t" == res.data

test "basic recover static long":
  let
    shares =
      ["C8EF4C4201", "9673E6A402", "2AF9D99203", "992DC30904", "25A7FC3F05"]
      .mapIt(parseShareHex(it))

  let
    res = shares.recover()
  check "test" == res.data

test "basic split & recover short":
  let secret = ShamirSecret(data: "t")
  let shares = secret.split(k=2, parts=2)

  let res = shares.recover()
  check secret == res

test "basic split & recover long":
  let secret = initSecret("super secret")
  let shares = secret.split(k=2, parts=4)

  let
    res = shares[0..1].recover()

  check secret == res