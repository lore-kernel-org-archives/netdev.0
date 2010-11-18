From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 2.6.36 released
Date: Thu, 18 Nov 2010 00:58:21 +0000
Message-ID: <1290041901.30433.119.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-I5MMD19hWjG1WewKHnkH"
Cc: Jeff Garzik <jeff@garzik.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:49820 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232Ab0KRA6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 19:58:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--=-I5MMD19hWjG1WewKHnkH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 2.6.36 has been released.

Home page: https://sourceforge.net/projects/gkernel/
Download link:
https://sourceforge.net/projects/gkernel/files/ethtool/2.6.36/ethtool-2.6.3=
6.tar.gz/download

This will be the last release via Sourceforge.  A new home page will
shortly be created on kernel.org resources, probably at
<https://ftp.kernel.org/pub/software/network/ethtool/>.

Release notes:

	* Fix: RX n-tuple masks and documentation
	* Feature: Ethernet-level RX n-tuple filtering and 'clear' action
	* Feature: stmmac register dump support
	* Feature: get permanent address (-P) option
	* Feature: VLAN acceleration control

Jeff Garzik has handed over ongoing maintenance to me.  Jeff, thanks for
all your work on ethtool over the past 10 years and for your help with
making this release.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-I5MMD19hWjG1WewKHnkH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEVAwUATOR6KGkILBsOca60AQJUigf+OEWw6BYy70BZjwp9i4b2Eq0k6VViA4Y+
tZp8uTdSNhPMAVXCW7wYV2tA80QlbTtR/kUHbgBRxxgYL69JZTw3IzVXQ1XfYXjT
KLbpeTnOAJOlsAmwystKuPBgjYlpHtN6czXdTruGQrA5y2KD7O4lQMeYLPLaJLIC
7wCrwQCCSbTQxHN9LGyN01OQBPB93PMsbrYUAQIpW0EZ+7/795vEclKNSGtzTxEv
gyedkt2aoQdFdJEKAt7LqX1N9QToGde+dCfnoPI1PuJO5uezLGegaKyBp7WkgXWQ
FXjBJFAoVZII6yqNhgOl/2uDj5WITNiEEqqk2NDXyMyh/2aavGKyOw==
=PS90
-----END PGP SIGNATURE-----

--=-I5MMD19hWjG1WewKHnkH--

