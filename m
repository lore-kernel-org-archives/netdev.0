From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v3 7/8] i2c-pnx.c: Remove duplicated i2c.h
Date: Wed, 18 Apr 2012 20:04:20 +0200
Message-ID: <20120418180420.GC2548@pengutronix.de>
References: <1333528480-17134-1-git-send-email-stigge@antcom.de>
 <1333528480-17134-8-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2/5bycvrmDh4d1IB"
Cc: arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	srinivas.bakki-3arQi8VN3Tc@public.gmane.org, kevin.wells-3arQi8VN3Tc@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org, jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333528480-17134-8-git-send-email-stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2/5bycvrmDh4d1IB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 04, 2012 at 10:34:39AM +0200, Roland Stigge wrote:
> The platforms using i2c-pnx.c both defined a duplicated i2c.h (used nowhe=
re
> else). This patch removes those and integrates the contents into the driv=
er
> itself.
>=20
> Signed-off-by: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
> Reviewed-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Applied to next, thanks.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--2/5bycvrmDh4d1IB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAk+PAiQACgkQD27XaX1/VRszwwCgiHRp1XFouJAIR5iV4ZYIcUIy
t30AnAxEkK4mKAOWedcSYupQYWYb1g9S
=9xmr
-----END PGP SIGNATURE-----

--2/5bycvrmDh4d1IB--
