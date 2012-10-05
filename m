From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.6 released
Date: Sat, 6 Oct 2012 00:15:31 +0100
Message-ID: <1349478931.2819.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-HtyswTwo0x25rOemy0th"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17636 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752548Ab2JEXPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 19:15:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-HtyswTwo0x25rOemy0th
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.6 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.6.tar.xz

Release notes:

	* Feature: Allow setting MDI-X state (-s option)
	* Fix: Preserve pause advertising bits when setting speed and
	  duplex with autoneg on (-s option)
	* Fix: Don't call ioctl to set EEE parameters if they are the same
	  as the current parameters (--set-eee option)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



--=-HtyswTwo0x25rOemy0th
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJQb2oTAAoJEGkILBsOca60ctAIAKEYBzswv19nIdO5+pE9aPC6
hrEmvwTQnIisrvFAbjnHhNWZ1eyYygOfFc5aPh7YEHQR8cdNBtkFg77CEIOo3Njm
6UsMGSHG90XMEwFd+21jINoZxmGZK/0/tV36r2nr8F2mAebpF0pVR4PElQ3umrW3
J7Gcz4tOBi/IB6PKNmLuaANiVlu5oN9puVRe6cZgWBdGRUGPNpFmpbBZbEfnOdc7
kdNkqM/TFvxi2qOxCemoJu2QCDvrphi8mx0pdAK/uOIx9rM+mWuqHJE4uGyRXqfO
SlCaV4gos6Bg5hZejMe6+kiD7cBjLUV420AbAtBCFEliI8kTLPmReRgQDB+7qKw=
=FgwZ
-----END PGP SIGNATURE-----

--=-HtyswTwo0x25rOemy0th--
