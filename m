From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can-next 2012-06-04
Date: Mon, 04 Jun 2012 17:52:08 +0200
Message-ID: <4FCCD9A8.7030207@pengutronix.de>
References: <4FCBEAAB.90708@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig63B92FC639C11DB24969A8A6"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4FCBEAAB.90708@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig63B92FC639C11DB24969A8A6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/04/2012 12:52 AM, Marc Kleine-Budde wrote:
> Hello David,
>=20
> here are the first patches for net-next, they add power management
> support for the flexcan driver and clarify the documentation with
> respect to error messages.
>=20
> regards, Marc
>=20
> ---
>=20
> The following changes since commit 31a67102f4762df5544bc2dfb34a931233d2=
a5b2:
>=20
>   Fix blocking allocations called very early during bootup (2012-05-21 =
12:52:42 -0700)
>=20
> are available in the git repository at:
>   git@gitorious.org:linux-can/linux-can-next.git master

That should be:

git://gitorious.org/linux-can/linux-can-next.git master

Sorry for the noise,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig63B92FC639C11DB24969A8A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/M2agACgkQjTAFq1RaXHPqwACeKSXPOiWZT0YQbZKqNt/sWRPI
/n4AnA7JNQ/h9S7sSrD3qtclAIDdtuud
=UojC
-----END PGP SIGNATURE-----

--------------enig63B92FC639C11DB24969A8A6--
