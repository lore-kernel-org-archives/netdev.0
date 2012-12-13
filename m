From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.7 released
Date: Thu, 13 Dec 2012 18:57:17 +0000
Message-ID: <1355425037.2623.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-kdoREC3kFR5OQ+6MPMoa"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10279 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab2LMS5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:57:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-kdoREC3kFR5OQ+6MPMoa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.7 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.7.tar.xz

Release notes:

	* Fix: Gracefully handle failure of register pretty-printer (-d option)
	* Feature: Add support for et131x registers (-d option)
	* Feature: Basic optical diagnostics for SFF-8472 modules (-m option)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.




--=-kdoREC3kFR5OQ+6MPMoa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJQyiUNAAoJEGkILBsOca60xjIH/ipZUASeDIwAJhXAlkWU8j3a
fqIe8QyjDRhmIVWkjfNatqekp7zMwI1q3IbxiBFVgbxCrPy3GDISQ/DaJe2PgH3A
2UvgMgNs15AXuW+QfIEu+mRHzV/BuUrTEVqZOgpG92TeH50O3UnY1InoVIHvtCC4
xY0RkxlEZjFlcYu4AsdqGZBTOIHJ9pG3Ml6w7F/LDD5LyqFh1z9rIlzAHi8ie2TW
OIY+SsMvk+RHqIsJJuUXv4FuODY4vZrnCsDu4yxTtkspJC6ftz6P0r1Pr5N0Gzb1
fGjlzQstqYFby0ZY88VFlg2uk10gCB4IYKMt6E/DiwArNUrCroLFDCCSYjBqhbg=
=2HFM
-----END PGP SIGNATURE-----

--=-kdoREC3kFR5OQ+6MPMoa--
