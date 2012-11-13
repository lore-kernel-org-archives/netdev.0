From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [3.0.y, 3.2.y, 3.4.y] Re: [PATCH v2] r8169: Fix WoL on
 RTL8168d/8111d.
Date: Tue, 13 Nov 2012 20:24:41 +0000
Message-ID: <1352838281.16264.106.camel@deadeye.wl.decadent.org.uk>
References: <20121101222113.GB7708@electric-eye.fr.zoreil.com>
	 <20121112163858.GA4343@elie.Belkin>
	 <20121112230339.GA28555@electric-eye.fr.zoreil.com>
	 <20121112.182754.384199300061351360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LWof8aclMGFufVWbgLoz"
Cc: jrnieder@gmail.com, stable@vger.kernel.org, kibi@debian.org,
	netdev@vger.kernel.org, nic_swsd@realtek.com,
	hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	florent.fourcot@enst-bretagne.fr
To: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121112.182754.384199300061351360.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LWof8aclMGFufVWbgLoz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-11-12 at 18:27 -0500, David Miller wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Tue, 13 Nov 2012 00:03:39 +0100
>=20
> > Jonathan Nieder <jrnieder@gmail.com> :
> > [...]
> >> This has been applied as commit b00e69dee4cc in mainline; thanks!
> >>=20
> >> Fran??ois and David, would this be a candidate for inclusion in
> >> 3.0- and newer stable kernels?
> >=20
> > - 3.0.51
> >   b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
> >   aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
> >=20
> > - 3.4.18
> >   0481776b7a70f09acf7d9d97c288c3a8403fbfe4
> >   b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
> >   aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
> >=20
> > - 3.6.6
> >   0481776b7a70f09acf7d9d97c288c3a8403fbfe4
> >   b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
> >   aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
> >=20
> > I'll cook the patches.
>=20
> Thank you, these all look fine for -stable to me.

I've queued up all three for 3.2.

Ben.

--=20
Ben Hutchings
For every complex problem
there is a solution that is simple, neat, and wrong.

--=-LWof8aclMGFufVWbgLoz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUKKsiee/yOyVhhEJAQp7GRAA1iSSgTnp/o7TGnyZsYHJEA/opDtC48JY
sXUORFOZs5PZVNZnCtwO4EQr5RrJkRq00I7EwbynUIUOMdwiKydoWH+xauWE7gbC
CDAqaRUnuA+u+DFEW4LPVh4s0wWxjE9XhA9TJrYEeBVFjiwxNI53j+8mauwWXVO7
vNcOevfdjs86ctWgzpeoAMP4IwNObCUbJdQxSIINwNpPC+4+4iVzLJj68PDFBcCJ
p9Q8Oi4XWnZlC/Ap+Sm6wkHHvKB1iIqOkF5SIh/EOD2fcDutVypI7W5RnVbLZtS2
qhHUBOgrn3m6oxLXbn9lB1rGuAqa8Ihya2giamtG0E4GGs6PJwWinFz3CZRLGv1r
TWi8gwz0bZENY5wMmhCnZVgkA8yBCx4C1V1Xuhj51+JU8RTmRzUzi8feJSgxRxOk
3l8NKrbPUpfJQNbyFnGC9VwDrYyBnQRUSD/cgoXoBbPk1ps40xZvxuYFjcMUk595
MU3EX1cBW6NxQYik62TDfSm/DrI7sNMKRgUnprA+Mc+psWa8dJ1kvMy4a7j1rOyr
FIxeDaTFzdQ7EmkCCrLwxMafhDRFzb04+YHXqHgWztOi9//wKsniEeKIGo/WVE2V
0uoo888oSyeFA657pGxpkkDC4hp1/bfHlvvPH5KXPCezIGJ/8tTMlSqkFqXqO5wA
oFG0BuWu81A=
=Wrk0
-----END PGP SIGNATURE-----

--=-LWof8aclMGFufVWbgLoz--
