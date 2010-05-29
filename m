From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] netdev/fec: fix ifconfig eth0 down hang issue
Date: Sat, 29 May 2010 02:40:13 +0200
Message-ID: <20100529004013.GA12507@pengutronix.de>
References: <1275037685-14555-1-git-send-email-bryan.wu@canonical.com> <20100528144506.GB13777@pengutronix.de> <4BFFDDAC.7000909@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Cc: davem@davemloft.net, afleming@gmail.com, s.hauer@pengutronix.de,
	gerg@uclinux.org, amit.kucheria@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60623 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab0E2AkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 20:40:19 -0400
Content-Disposition: inline
In-Reply-To: <4BFFDDAC.7000909@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> The performance drop issue still hangs in my brain. As soon as I have a n=
ew
> patch, could you please help to test? Or do you guys found any performanc=
e drop
> solution on your hardware? IIRC, you reported similar issue as us.

Sure thing, I will test it. We use your old patch meanwhile, but I haven't
looked into performance issues yet. We needed to solve other issues with th=
is
board so far.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwAYm0ACgkQD27XaX1/VRt9IwCfWo08QdBeksnM5dsKv9uxeVRr
/68An3qej2ps5XfOA0gbskP+8C0fVDt4
=HIyZ
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
