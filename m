From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [RFC 1/3] net: freescale: fec: add support for optional
 enet_out clk
Date: Thu, 31 Jan 2013 16:12:35 +0100
Message-ID: <20130131151235.GC3400@pengutronix.de>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
 <1359470773-14290-2-git-send-email-w.sang@pengutronix.de>
 <20130130052547.GA23670@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="iFRdW5/EC4oqxDHL"
Cc: David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Shawn Guo <shawn.guo@freescale.com>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34849 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab3AaPMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 10:12:42 -0500
Content-Disposition: inline
In-Reply-To: <20130130052547.GA23670@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--iFRdW5/EC4oqxDHL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 30, 2013 at 01:25:50PM +0800, Shawn Guo wrote:
> Thanks for working on this, Wolfram.
>=20
> On Tue, Jan 29, 2013 at 03:46:11PM +0100, Wolfram Sang wrote:
> > Some MX28 boards need the internal enet_out clock to be enabled. So, do
> > this in the driver iff the clock was referenced via devicetree.
> >=20
> > Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
>=20
> Acked-by: Shawn Guo <shawn.guo@linaro.org>
>=20
> > ---
> >=20
> > davidm: Please don't apply before Shawn as the mxs-maintainer has given=
 his ack
> > on the general procedure. Or maybe he can merge it via his tree?
> >=20
> I prefer to have the patch go via net tree for 3.9, and then we clean
> up mxs platform code from 3.9-rc1.

Fine with me, too.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--iFRdW5/EC4oqxDHL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlEKieMACgkQD27XaX1/VRspxQCdG01bAnnZywia73+BTt8FQURF
XHIAmQHvNGq/e4FKdz9lZub0yA+2ZvkX
=tdT+
-----END PGP SIGNATURE-----

--iFRdW5/EC4oqxDHL--
