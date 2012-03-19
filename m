From: Mike Frysinger <vapier@gentoo.org>
Subject: iputils git tree
Date: Sun, 18 Mar 2012 21:07:42 -0400
Message-ID: <201203182107.43855.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2060073.7bvaL6F6O7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:35656 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043Ab2CSBHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 21:07:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2060073.7bvaL6F6O7
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

the iputils homepage says to use:
	git://git.linux-ipv6.org/gitroot/iputils.git

but attempting to clone from that gets me connection refused.  the gitweb is
still alive though and shows recent commits:
	http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/iputils.git;a=summary

so where can i clone this tree ?
-mike

--nextPart2060073.7bvaL6F6O7
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPZobfAAoJEEFjO5/oN/WBCScQALmFhVso7Hy0PDGWguZNr3Wi
RnbDaBq8ZvurJBWszaznsSH1q2BjwKFqejzZ02EcWS6O1wF7fz8xRWHSi7G6cdzC
VlwHymv+tBe3KDJqaIoYUOJWKw53aQhqceHTg3K+g1MLv2xY7uJfhYSQWIH4l1qZ
U0cvGTYw1B9anfbqmZJU5xkzDBTeKyXxPwomMF/FLIZ9NfU4SZLrOopbb0pfQtev
Kihgi9c9J+8i5CDaH1Dnc5N73pqPEk5VyMasLnQ9+usuU/smQlp3YK4YxA1LH0gR
hyotIG4yrMh/u2HpkTdBzWJAMlomVQxQMVgKlr4xJhhQ0kFcGalL2eNyfYJa1bcj
RRK1Xh2RXoT3ikW6WAdA80C15sb6bUmbJtBicXdBeds737aV7W3Sxrn3VwnD4RPw
R4x/f8IU25XLHPzSe/cI/+a7iyhJMystdaCbcK2B2oZqM/uqiAXdgEka0W9J8Pz2
IrxRfrKEH3CCAmivssD0iNbt0Abw92o/C+ROeprRJ26TTraoL6OCQ795sJ8Sm3L1
QF70O/gEu81+w9z0ragqq+3LhfRjEO48FU1NbhQ9kECJg+xC0VSavMSa5I3y9wn5
e+fSGVQo+5JiuDW4RlfCUCZLJwhYC93WGPSCB5Gfi9hg+LSNDhGAAgo2uLsdAXXW
CZ7kdmFgDnCgAgqQrwZS
=7ZPF
-----END PGP SIGNATURE-----

--nextPart2060073.7bvaL6F6O7--
