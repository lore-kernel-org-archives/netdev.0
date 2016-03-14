From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool 4.5 released
Date: Mon, 14 Mar 2016 01:58:38 +0000
Message-ID: <1457920718.3331.91.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-j07/SHgefwye3rVVLf8f"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42656 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750701AbcCNB6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 21:58:46 -0400
Received: from [2a02:8011:400e:2:6f00:88c8:c921:d332] (helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1afHmO-00089t-N7
	for netdev@vger.kernel.org; Mon, 14 Mar 2016 01:58:44 +0000
Received: from ben by deadeye with local (Exim 4.86_2)
	(envelope-from <ben@decadent.org.uk>)
	id 1afHmO-0005Zk-Mu
	for netdev@vger.kernel.org; Mon, 14 Mar 2016 01:58:44 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-j07/SHgefwye3rVVLf8f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 4.5 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.5.tar.xz

Release notes:

	* Tests: Fix missing function declarations when building tests
	* Tests: Fix return type of test_free() prorotype
	* Feature: Add PHY statistics support (--phy-statistics option)
	* Doc: Properly indent sub-options in man page
	* Feature: Support setting default Rx flow indirection table
	=C2=A0=C2=A0(-X option)
	* Fix: Use 'sane' kernel type definitions on 64-bit architectures
	* Fix: Don't ignore fread() return value (-d option)
	* Fix: Heap corruption when dumping registers from a file (-d option)
	* Fix: Stricter input validation for EEPROM setting (-E option)
	* Fix: Fix strict-aliasing compiler warnings in marvell.c
	* Tests: Fix use of uninitialised variable in test_realloc()
	* Tests: Fix compiler warning in test-features.c

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.
--=-j07/SHgefwye3rVVLf8f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW5hrPAAoJEOe/yOyVhhEJfz8P/jV3xzFEL2Ayobu4PY/jNmTP
emYKv9hmzHSjaTNABD/KGX2opCXYR4+NUYVprT+o06L53XhlxYpuJTvV1RYy8+ke
X4iqyJztBld7AHbZ3wj6Gp+OexgknuVsVP8Ronu7cig+Zwp+0ya6d0AZ+qwf2ZyL
dy/fTZwlw/4h54URdz5MMPMbHT7RSDvypj2vgGjahJ6b+ucw3cdaFrDQZsKTfIta
g/DklIlhy4WosgWYsZ5WuXdSZZxkw5oQ60lK4NPZMnl8tFS2rqeBwNCmSpznkbPI
NqDztaKPoSEVz8bNGbyy+QVGG5fFYRIV4AIUBd28zrmPbUraooayp4wjMNhYsyu/
XemT0SWomOEomZWWjo37g8RrZTyX2qVVoFbzZ4LeH0H1gbQ3HKr/Qlc12p948Azz
wAuFHPbsQQuvE2D56EEZpPNjghsvysJQ8TvciSccGot+ZhgIennsPtMR/eLdLTq1
URftl8Qx3uAaIO5B0DbjxleCpqO33/kBubdC3QeVLshBFo1zpi+dztxOkJC4ccw6
hmOqX6T1r+EFMuMSnJmGC8yBgccXQNN7xxhhD0MZ+Bdw12F1KGaRGDtgjInDo2Mc
s4XuCGVNS7JUqqeMiRictpBbSED+e6/pNTRzrv4sizD58ZBteg64BXvr/H13iJkp
KUrg4K23SltgbG7rjXaL
=KKUu
-----END PGP SIGNATURE-----

--=-j07/SHgefwye3rVVLf8f--
