
import unittest
import strutils
import base64

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
  let res = recover(shares)
  assert "t" == res.data
