From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.1 released
Date: Mon, 5 Dec 2011 18:51:39 +0000
Message-ID: <1323111099.2887.3.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-FIRu56bSGfGrzqr77aKE"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45678 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755470Ab1LESvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 13:51:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-FIRu56bSGfGrzqr77aKE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.1 has been released.  (It was actually tagged on 16th
November but I only managed to upload tarballs today.)

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.1.tar.bz2
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.1.tar.gz
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.1.tar.xz
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.1.tar.sign

Release notes:

	* Fix: Show all non-zero registers for tg3 (-d option)
	* Feature: Add support for external loopback test (-t option)
	* Fix: Show correct flow control registers for Intel 82599 (-d option)
	* Feature: Add support for reporting and configuring numbers of
	  channels/queues (-l and -L options)
	* Feature: Report pause frame autonegotiation result (-a option)
	* Doc: Change device name metavariable from 'ethX' to 'devname'
	* Doc: Fix various layout problems
	* Cleanup: Reorganise and add test cases for argument parsing
	* Fix: Strictly check for extraneous or missing arguments; in
	  particular, fail if the device name is missing

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-FIRu56bSGfGrzqr77aKE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJO3RK4AAoJEGkILBsOca60v1YH/2PZtcjUGVq04lVr6Hum/Imd
gkD96dw/QOJ7gOId0aC58SFlwI9I3Ghz4RUsLiVEmmnBxju8eA8XD8MThk7jLSmL
1Vk6Zx5zjaGNC2H3ld7xfRq8Us/h1qr6YC51t1gHaZWzuLZx7Hn/ivTjZJwatgrr
O8CXS6/tdkcANNKa78U77zJRbxsk+xBrRmcCeTQgGhUj9DjGArU4Uc5gyyQjvZxT
FpYjkIwfj7hW4CqKgyMWtR3bkPBDYsvqhqzHsBppALuUEFPU8yc5fnbCV9fe9afd
hF9cq7VEOLoF7Ft+juhG0BVtKnLQl9MSSHekwIwL8JOfEFrarTDIztRCcssv2tM=
=pXXc
-----END PGP SIGNATURE-----

--=-FIRu56bSGfGrzqr77aKE--
