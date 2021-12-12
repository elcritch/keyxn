
import unittest
import strutils
import sequtils

import keyxn/shamir

test "basic split":
  var secret = ShamirSecret(data: "test")
  var shares = secret.split(3, 5)
  check len(shares) == 5

  for share in shares:
    check len(share.data) == len(secret.data) + 1

test "basic recover static short":
  let shares =
    [ShamirPart(data: "0E4A".parseHexStr()),
     ShamirPart(data: "9954".parseHexStr())]
  let res = shares.recover()
  assert "t" == res.data

test "basic recover static long":
  let
    shares =
      ["C8EF4C4201", "9673E6A402", "2AF9D99203", "992DC30904", "25A7FC3F05"]
      .mapIt(it.parseHexStr())
      .mapIt(ShamirPart(data: it))

  let
    res = shares.recover()
  check "test" == res.data