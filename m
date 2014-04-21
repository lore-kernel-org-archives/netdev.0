From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool 3.14 released
Date: Mon, 21 Apr 2014 23:37:24 +0100
Message-ID: <1398119844.3624.159.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-A6BoUzlEstzwl+jDFRFt"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51341 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754027AbaDUWhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 18:37:34 -0400
Received: from deadeye.wl.decadent.org.uk ([192.168.4.249])
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <ben@decadent.org.uk>)
	id 1WcMqC-0007Zy-Uw
	for netdev@vger.kernel.org; Mon, 21 Apr 2014 23:37:33 +0100
Received: from ben by deadeye.wl.decadent.org.uk with local (Exim 4.82)
	(envelope-from <ben@decadent.org.uk>)
	id 1WcMq9-0000JD-2N
	for netdev@vger.kernel.org; Mon, 21 Apr 2014 23:37:29 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-A6BoUzlEstzwl+jDFRFt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.14 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-3.14.tar.xz

Release notes:

	* Fix: Report Backplane as supported port (no option)
	* Feature: Allow building a smaller executable without pretty-
	  printing of register/EEPROM dumps (./configure --disable-pretty-dump)
	* Fix: Typo in channel parameter format in an error message (-L option)

Ben.

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-A6BoUzlEstzwl+jDFRFt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1WdpOe/yOyVhhEJAQrS5Q//TqLEGdKD1R9CGyyezt1NSvzTguE/6QU9
boNmfzv+04K0qWiVwqgdpsX3hFo3utuoqNBqGI4/24d16kiLToGPsc6JE508lg2j
ulhs6kjXVSbq/6bCXWH+Fffb4zM4QTQsbQ0lnLEVivgTyMRXV5YC06Hf1gPY88YQ
tJrUzH4R0lmDalvMPxC4eYAkBe4ZnsQK/ic0NL8FaT0sBPKwnZsYqrQV/exOQydr
ZlSK46HG1/ci6ybWUVKpWoXEyHvlKWvrwWXA8ynJubeXsUw/Ao93rru2vXtbER4a
HAYwgpeT5BOGCg/+OlaS0hYp7MavE7l1uk7oAj3ngyYmC+UtGfEfnBaLr8LUkbqf
kUSBrIGNU9p69M8+sec8o5FUBDeRxBoT2ZSBFcBmT7UuC2FHa66bgS5c0Dpfjew+
kflrXAGuKDkiC97SiRLeKkcVkP46KSVIb867Zbd7LjPxoa6k4xBWwChmOGypeh2c
/uMP4XvdZopdsg4zqlIr8YlPNXXfZ9fGzR9eWXWwLbZRtI2ggALT3MmQoNpUu6Yd
QGecoeSP4G6M46QPZy6wKjbq0BGgLPaNuk+4Ma9uIIhco1Jit9GeJzS2J5JpgAor
sJpaBFWA9EauFRe2QRgHCsIQqTf8YX2K80jQyQ+/PzFp7AsX+xhyU9RH8lR42IzL
3TPdckWw4EA=
=nQ8l
-----END PGP SIGNATURE-----

--=-A6BoUzlEstzwl+jDFRFt--
