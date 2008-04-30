From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/RFT 4/4] mac80211: use multi-queue master netdevice
Date: Wed, 30 Apr 2008 17:38:14 +0200
Message-ID: <1209569894.18659.53.camel@johannes.berg>
References: <20080430124055.091382000@sipsolutions.net>
	 <1209566743.18659.30.camel@johannes.berg>
	 <1209567609.18659.33.camel@johannes.berg>
	 <200804301734.11804.IvDoorn@gmail.com>
	 (sfid-20080430_173024_071316_D8372DE5)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-RKP+TU59Pp4u6iRPrD75"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47783 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbYD3PlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 11:41:04 -0400
In-Reply-To: <200804301734.11804.IvDoorn@gmail.com> (sfid-20080430_173024_071316_D8372DE5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RKP+TU59Pp4u6iRPrD75
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-04-30 at 17:34 +0200, Ivo van Doorn wrote:
> Hi,
>=20
> Don't want to spoil the fun, but the following part doesn't compile
> when CONFIG_MAC80211_QOS is not set.

Oh! I hadn't tried that yet, thanks. I had tried not configuring it and
tested the Kconfig for it, but evidently not compiling.

johannes

--=-RKP+TU59Pp4u6iRPrD75
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBiSZaVg1VMiehFYAQKO0hAAoYp2hYa8py8lyGWT2fKZB/CWC5UaaJGd
2MhczNlJzQKDDQlqoo4eO1pN/vbeZbShjuWe8+py7kWzgKN4cPNDwFVJ6hK0ruQr
0doKW6w/XPiD3AAwCXfcjXw5qwEO477gDQ+m5nXfK1KXn9fQCv9odUOGx7u2Z08i
hWGCqL86kDEgHrVInZ8XmPyDg/Ul/rL5FwnkxnKOrnsAf+zOHiNRQwJXZOri8FPd
oC6LWKkRMQWqceQHNILxgv+H/CyycIMLzqyVjKMxk/5Td36hu0YHrTV2lhcoCCND
CiLx+6peCJw0PlxlKSVKw1/+nOKRzSJO/X6dP7br5pB1ALDwyGbIiPnab91IKbE0
3nOo7o+/4UX5I3SBue3/x7DD4yXEABafeH2qXR4ZYGu7QRbj/IFBHPCSSsH32YTd
CtGXOvjhjq25pug15ya3mS2DB8onKobnvfHui5II/jUWdauc2Xp6JnWVQQJ8laZ/
/tz5I3nxHb11Q3xjGtKD2A37OHJ/2SlJbcMtYxy4Z0Pi7NmMqVBFg8bP9glhdr2c
WDou4ngNPOJ/4LkWemQm3yDdYyUvN7wxa7HcWlcl0oBRh7RWAR6gQk6ypNH63dKL
8vqH26AJMtEtF0txKdtqZ5UDb2ss1C9XJP9FF9GBeOmiIM52czf5Zn+nzuSMfmYI
7r2BH8ihu+M=
=U6Hp
-----END PGP SIGNATURE-----

--=-RKP+TU59Pp4u6iRPrD75--

