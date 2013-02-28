From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.8 released
Date: Thu, 28 Feb 2013 15:04:29 +0000
Message-ID: <1362063869.3599.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-9vGjL4D1M0oE8kShRzwD"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26563 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932502Ab3B1PEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 10:04:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-9vGjL4D1M0oE8kShRzwD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.8 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.8.tar.xz

Release notes:

	* Feature: Allow setting destination MAC address in L3/L4 flow spec
	  rules (-N/-U option)
	* Fix: Show full 64 bits of user-data (-n/-u option)
	* Fix: Add version check for et131x regs (-d option)
	* Doc: Improve description of -f, -t, -s, -N/-U, -W options in man page
	* Fix: Restore 20000baseKR2 cap display (no options)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.




--=-9vGjL4D1M0oE8kShRzwD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQEcBAABCAAGBQJRL3H9AAoJEGkILBsOca60cPkH/jRVyuhxzF/WIxa7UnKlHH9X
H5eGDUAIdR1tBbIkZe1xW4tqoqdZIhqFMpTvW1Igrb7z6QYsVY0uxP2OoklosuPu
0Lf5MCxv7urprm2AH3Lxfgt9SGozoXosRiFhaw9xj8GVrCWmbDSLGqfB/Fj1SnfA
uW+pHz5HhEDLvh+11YxXRgNLoThW031LpDwD6/ITrJTaWjkRUwO6d8v3xGXGIjkK
kPsP8HA19Ouj8RPHwBbLIBu6M/OqM+TzxPhqoU0Xq1GegVQyokKEoalZ1BxkjwvR
/ISlYPELSYtovP/4h7/E0Uy2rzyPxp+i0VNL75XfTquvfqV/JmLnYDYwaCkwp1E=
=l+g0
-----END PGP SIGNATURE-----

--=-9vGjL4D1M0oE8kShRzwD--
