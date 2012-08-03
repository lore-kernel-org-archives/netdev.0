From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.5 released
Date: Fri, 3 Aug 2012 20:48:37 +0100
Message-ID: <1344023317.2610.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-BrKF9FIvPFofbBnIjo8c"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43275 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752328Ab2HCTsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 15:48:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-BrKF9FIvPFofbBnIjo8c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.5 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.1.tar.gz

Release notes:

	* Feature: Display support for 1000BASE-KX and 10GBASE-KX4 link modes
	* Feature: Energy-Efficient Ethernet (EEE) configuration
	  (--show-eee and --set-eee options)
	* Fix: Don't trust drivers to null-terminate strings
	* Feature: Display support for 40G link modes
	* Package: Update RPM summary, description and URL
	* Package: Exclude redundant documentation from RPM

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


--=-BrKF9FIvPFofbBnIjo8c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJQHCsVAAoJEGkILBsOca600F4H/iJIcE8tKkL1iwN313G2c/ty
1rA7uHkjg2MTzxGe+r9OQmeOcaVHUDqnFoczuMIle/L9LyOYXfNlaj+wlvoWwO6F
Lm7dswXki7/74AgYhP9FFvDHZL7P9XC591/RKWQgUo0NsPPYD8H7WoCPRVjmKCVs
O6/npfdyTWDexn3zDTwr1wP1FvTbD89E3s4vQbUujqI1K32aACHWa837gCsXP0UV
LnK8weSlq8cjkuxa/sqCfZ7nl4XDAsh4EriPEuTnuJ0mrRjguH/2HLYArvZbD0Pv
vF1jo5df/admRAs2ubviEIlMs+QITpXsShlh2pkOyTXKrlZbYwLdMh8SOdjuUbs=
=4PKS
-----END PGP SIGNATURE-----

--=-BrKF9FIvPFofbBnIjo8c--
