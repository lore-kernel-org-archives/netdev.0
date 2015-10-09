From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool 4.2 released
Date: Fri, 09 Oct 2015 03:49:45 +0100
Message-ID: <1444358985.2956.293.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SeUaRqSnG4saDvQ/2aU9"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36421 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754582AbbJICuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:50:01 -0400
Received: from deadeye.wl.decadent.org.uk ([192.168.4.247] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1ZkNkt-0002dN-Vo
	for netdev@vger.kernel.org; Fri, 09 Oct 2015 03:50:00 +0100
Received: from ben by deadeye with local (Exim 4.86)
	(envelope-from <ben@decadent.org.uk>)
	id 1ZkNko-00013W-S1
	for netdev@vger.kernel.org; Fri, 09 Oct 2015 03:49:54 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SeUaRqSnG4saDvQ/2aU9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 4.2 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.2.tar.xz

Release notes:

	* Feature: Support soldered-on modules in module EEPROM dump (-m option)
	* Feature: Add register dump support for VMware vmxnet3 (-d option)
	* Feature: Update register dump support for IBM EMAC (-d option)
	  (requires Linux 4.3 or a future stable update to 4.1 or 4.2)
	* Doc: Fix typo in man page

Ben.

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.

--=-SeUaRqSnG4saDvQ/2aU9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVhcrSee/yOyVhhEJAQpB/Q//Sl7Y0GTmOlwPD+suy6K9iebH4XBKwCP2
qRNLf9ddjxdoTedHG0a2GPc2ShBrmnsumEM8Q69kUoXPQUl+MVR5WucvL76Lz+DY
a3l42LjxMUc57vywe4aX3RdV4CLc/iypEWhq0eeS2yWi6sH3GEx8uZEZGvvSV4+Y
X/p1he7sRzPGzBIUYv09bYxm9nMCH+IpklEwiSYeiuyPlPJVkVMm1cvpUT8LkF7O
+eSHOWY44riDKJs/4+HJ6bMPEkRlnAqf3EOPc5/pyPVIzUgxY1RCptuQyq5JSj9s
boPJOFKOPLyR0BZAPN+pbsjvkN5rpKK9fXfN4O9Vl78zn5evQdMredfhJwfpnZCe
n/HBOxBjFnRWXHGMReWL+nUNouJvL4OXWMMWKM7CwVtxB/7fAnNhliNmlfow3OeB
/zTHmEA7Z8K16BUNdU3JO3d7sOlbMc9NpFegR5qtJO3iQwJuznV1q+h4razX9iMR
yOfAQ8g3egO7/v4RmJbvbXKELDYFyOVGiLteU13pSjTRph+pXLM+RYhZksCIsydn
QOxC//u0/igua3B8p8aDj8kU6O8cFwLzGPBEN7/Ik5BujqLxY8G5L8glK7SwHLgt
XlE7EVxjTL47zE7lpe4pn4WGeAwRzhnwJ/tnrc3X2Vk/Bg7kTUGqesFF9XteoRyj
3coZvrWGXgU=
=s1AW
-----END PGP SIGNATURE-----

--=-SeUaRqSnG4saDvQ/2aU9--
