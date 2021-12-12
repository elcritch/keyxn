
import unittest
import sequtils

import keyxn/shamir

test "basic split":
  var secret = ShamirSecret(data: "test")
  var shares = secret.split(3, 5)
  check len(shares) == 5

  for share in shares:
    check len(share.data) == len(secret.data) + 1
