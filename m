From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.4 released
Date: Fri, 8 Jun 2012 18:04:12 +0100
Message-ID: <1339175052.2648.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-BxLuo3jjNCYh6ToLkbNQ"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29563 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761333Ab2FHREY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 13:04:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-BxLuo3jjNCYh6ToLkbNQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.4 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.4.tar.gz

Release notes:

	* Cleanup: Merge RX NFC options
	* Doc: Improve description of RX NFC options
	* Doc: Add ntuple to the -K option in the man page
	* Feature: Show time stamping capabilities (-T option)
	* Feature: Dump plug-in module EEPROM (-m option)
	* Feature: Show and change all generic net device features
	  (-k and -K options)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-BxLuo3jjNCYh6ToLkbNQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJP0jCMAAoJEGkILBsOca60+48IAJfC1vRStRkeF0HoDxxoFiOP
KGihSdkTgq/xVbg5cDOjkMpeNjQUBQOUu23gfR2G4DJnkIQZqdyVpq9o435p7bfE
Or9A5ilvTK8pbZFdH1FyGnX1CWKcc9ZhEo0NTvJaswPWIiUmCgOzHIV5g/35ReVy
hoUfSBgbxuSdFpDLF9B/2SnhDQGd23ITjP3l8+nRM8tguquONXkxSWOUI7wFaLii
ywhVLudl5NcZXVTxUQTapNE0I56dAdKFnKldlgz8zfJCCGFZ18bRbCF5bCFB8GBY
Kgh1aIHlv5r7waMlF/QKdytpoG6Bj/ZFlFulClgRmvOcnS+Poki2WPrK9LIy9Ek=
=J5vK
-----END PGP SIGNATURE-----

--=-BxLuo3jjNCYh6ToLkbNQ--
