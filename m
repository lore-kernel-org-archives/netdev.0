From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 0/4] net: cpsw: fix hangs and improve IRQ handling
Date: Fri, 2 Jan 2015 15:53:35 -0600
Message-ID: <20150102215335.GI4920@saruman>
References: <1420222228-31949-1-git-send-email-balbi@ti.com>
 <20150102.164536.1906626949656646358.davem@davemloft.net>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gJNQRAHI5jiYqw2y"
Cc: <balbi@ti.com>, <mugunthanvnm@ti.com>,
	<yegorslists@googlemail.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150102.164536.1906626949656646358.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--gJNQRAHI5jiYqw2y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 02, 2015 at 04:45:36PM -0500, David Miller wrote:
> From: Felipe Balbi <balbi@ti.com>
> Date: Fri, 2 Jan 2015 12:10:24 -0600
>=20
> > In any case, patch 1 should go in during the -rc an get backported
> > all the way back to v3.9, while the other patches can (should) be
> > delayed for v3.20 merge window.
>=20
> If that's what you want, the way you submitted these changes it not
> the correct way to do it.
>=20
> You should instead submit patch #1 all by itself, correctly targetting
> 'net'.
>=20
> Then, after the next time I merge 'net' into 'net-next', you can submit
> the rest of the changes.

then take patch 1 and I'll resend the other in a couple weeks, no
problem.

--=20
balbi

--gJNQRAHI5jiYqw2y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUpxNfAAoJEIaOsuA1yqRE4HkP/1WCa1+vf7zA2k9Db6clu4kU
2b06rpUkGCwx8l7fqRkP+im8TR9/QBQ6zYDTyb45j2jBb7dhqg/TN/nuPWJ9TDEd
GQO9SznyTFJByfvihEih+ljoeGIvISaQLm0Ppq50+Dh3ypwPXtjE7oohg24Yoa2L
RLvCVWwo8oQcMfsX6as+cyAEE3G0fmJk72oUyCo6z3/6Xyki8aez87B6oyzq6XMH
hoRcvuQhaHVK7mjVpNZm+8SyFU9Q1L0tw5+Q2ntGAn4A8uesJMA/3bTSMf5ZCBX8
jbdA6+vGhcGWr3tCdsJZj9cKDjONIK1RSm7uAoQvC4LPBM2VKQD9lLthwm4XlctL
Mu6gzXfbsXUZqZSif9J1TzgjSvbM4pJSvQ/obnP7FxzwOd+NzTcBeAdjAXGkzDcP
30ssjqKrzeeA6iL2XM6ZrbxDTYDkxEjkUwrILe9+TNsy25Ma7jqxub3NB1pJJ1mS
BWaa8FVqvDJI1yufSNnRxVTtJkFJ8nD0BOfZRTo1pzKxO4rsyK5P3KqE2xsuKmvH
yPIyWF9cOjfSioRHqN7qtWH+fZ3q3D9VowHNXckovRPUe2yhzD39JJTF7PmMEMKo
YYQSJ9D++d8V/LzdQZ3h5sg0Ym9ay5db6ihWK5QiT6RFuT5XWen6IPoM+t0ZECQX
ka/FzkTyvfiixJeRkF8Q
=WenU
-----END PGP SIGNATURE-----

--gJNQRAHI5jiYqw2y--
