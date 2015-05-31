From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool 4.0 released
Date: Sun, 31 May 2015 22:30:06 +0100
Message-ID: <1433107806.6319.141.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sQJtlm3mOAQPdI5GzeZn"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58789 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758488AbbEaVaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 17:30:18 -0400
Received: from deadeye.wl.decadent.org.uk ([192.168.4.249] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1YzAoC-00062c-QM
	for netdev@vger.kernel.org; Sun, 31 May 2015 22:30:16 +0100
Received: from ben by deadeye with local (Exim 4.85)
	(envelope-from <ben@decadent.org.uk>)
	id 1YzAo7-0005No-Ly
	for netdev@vger.kernel.org; Sun, 31 May 2015 22:30:11 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sQJtlm3mOAQPdI5GzeZn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 4.0 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.0.tar.xz

Release notes:

	* Fix: Formatting of RX flow hash indirection table when size not
	  divisible by 8 (-x option)
	* Fix: Add missing Advertised speeds (no option and -s option)
	* Feature: Add support to get expansion ROM version (-i option)
	* Feature: Include SFP serial number and date in EEPROM dump
	  (-m option)

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-sQJtlm3mOAQPdI5GzeZn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWt9Y+e/yOyVhhEJAQrgeA/9H1vvu0GiHTcRd2tMD9wQ+/vGo6LiriBe
8yuDD+iirUS9RygSUl3k3WrQMERC6r6AnYd806KBxbXjpXXu9qGEtlVbQxVq0QmW
0DtQsCalt2sXqP3/MVd7ggeVzbSYzVOm4oyrWGcnpm6y4mUe5Y2vu2hv+bw1851I
D20n+8M1i4QCXWS01vm2RfigARzgHgEP/zQtnmNsMIPxf3uSD9qkELc1UEQwEoIN
xy60DzuKPCUvlAcyPLWEbRf95UfxuI1gFm3qAzvK20F5O25lvllAZNR17H5fYAyX
ifw8ppDY8h/VyASYc9LXKMYSOa0kW+B1yqM83+zMOlFOn5NtMjpko+EnlYA6GBv1
FClDeO+XRyLj6Ro8MmgWF9tz30v0ZvhvDQ6AMPKwNTOieZ10qHGjXegeZQ8PXY5I
WPz+xh/dItWYG7dFlaERh/R4OEl5WQNVzWM22Hh0tPgRO090C6i+NIIPt5DWgvyg
DNBRkt9BWDYw5zixEm0i0Ol/x4WKMiQETcBeFcP600MCcztQePmJTcBL34bEIh/p
dd2fNR7UbgNTxq0sM+bGr1nKQLnahqpf4iq0J5uofrPsO0k/NGzQufRtn3tj3I4H
5XU0bXXrPOs94ww8t52eC9ePXUMOmWEE+wm9C+rPKRLIqCGBf4IhLd18bhAZs7Fq
la0qFHqr3pI=
=FCGw
-----END PGP SIGNATURE-----

--=-sQJtlm3mOAQPdI5GzeZn--
