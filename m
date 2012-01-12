From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.2 released
Date: Thu, 12 Jan 2012 16:46:13 +0000
Message-ID: <1326386773.2740.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-7ErpGIf5KcIDAfWBzzNA"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52814 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751514Ab2ALQq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 11:46:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-7ErpGIf5KcIDAfWBzzNA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.2 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.2.tar.bz2
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.2.tar.gz
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.2.tar.xz
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.2.tar.sign

Release notes:

	* Feature: Add support for querying and setting private flags
	  (--show-priv-flags, --set-priv-flags options)
	* Feature: Omit zero values in Solarflare register tables (-d option)
	* Feature: Allow driver to select RX NFC rule location (-U option)
	* Fix: Correct register dump offsets for Intel 82575 chipsets
	  (-d option)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


--=-7ErpGIf5KcIDAfWBzzNA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJPDw5VAAoJEGkILBsOca60lSQIAK7V/4byiid3vb5D5U4Tf9WH
UMW4zTSu/Gp/1jMk5bxP9r72sWcAFuyFao1fNlGoaTlt75ImR1e4nTw5HdXgBlva
4UaqDpo1E6Ed0fO8RltuD+UeVnnbUR1eCu7kM3wwLi1NADfEzPbHxi+EDCkQ1Cb0
YOvtQRSwBJPW7UufAIVMrQGslomxqn4eburhlS97eTxfCmOAGKCkRZueaaPvWGa0
4NM2ivtL27wW1bS9fOqZyAQ89n5+XlL0jFOEVb2uelHyAGpFgc57u52s8xk0BjZY
tgy4NFVFhvAvN9SXsHfKpylmkqmMdvJPDZiH6quNnGcDJZSnzL3iyYBrJaeiBBU=
=iuNE
-----END PGP SIGNATURE-----

--=-7ErpGIf5KcIDAfWBzzNA--
