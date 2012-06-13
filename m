From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.4.1 released
Date: Wed, 13 Jun 2012 01:31:52 +0100
Message-ID: <1339547512.15266.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-YS6dOOE0QtZq2I3rtRrN"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16009 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752182Ab2FMAcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 20:32:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-YS6dOOE0QtZq2I3rtRrN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.4.1 has been released.  This fixes a regression in
version 3.4.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.4.1.tar.gz

Release notes:

	* Fix: Work around failure of ETHTOOL_GSSET_INFO for unprivileged
	  users (-k option)
	* Fix: Report any unexpected error code from ETHTOOL_GSSET_INFO
	  (-k and -K options)
	* Doc: Fix the date of the man page to match the last update

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


--=-YS6dOOE0QtZq2I3rtRrN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJP1994AAoJEGkILBsOca609AgH/286LoMjCkY6qeOgCQrtxbJb
RYeW9d5XQgmM5B13xHIUlwujTEN3fVQU+sH0nxtLcXXYHqwwm2PYsyjnGcEWBEVT
BtveGv4+M+Bl6n/7ZNwAFAuBdYx9ocsxRvE65Voy96teEenXCh/kjBYHaSmurzuw
lkhJFmzk25qPI8Zs/A0RaEUUzNlw6XlDUoIXhg9mcqNEdjGFFtA4voIn9HgkJoXq
sAXsUsLa7KCwsR6Jeet1bKBx6CWfL5MHv6M/iuRgjnn5og7Vz6yEyCoio4rSsDmA
a+ek+Ph5zBqfU/hBr0IOgMIfNs0bDlNXtyc5zOmEe5mxYjyoI7AQOzegP4tKAEw=
=6NjX
-----END PGP SIGNATURE-----

--=-YS6dOOE0QtZq2I3rtRrN--
