From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can-next 2013-08-29
Date: Mon, 02 Sep 2013 21:06:10 +0200
Message-ID: <5224E1A2.1010302@pengutronix.de>
References: <521FB992.5080002@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="T4CrLkgH3rfKUh3Pr154f85gjdKKPhUgA"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <521FB992.5080002@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--T4CrLkgH3rfKUh3Pr154f85gjdKKPhUgA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

On 08/29/2013 11:13 PM, Marc Kleine-Budde wrote:
> this is a pull request for net-next. There are two patches from Gerhard=

> Sittig, which improves the clock handling on mpc5121. Oliver Hartkopp
> provides a patch that adds a per rule limitation of frame hops.

have you forgotten this pull request?

Marc

> The following changes since commit 7ec06da81d2b98859b558d8d551a0c4e3d95=
16a3:
>=20
>   net: packet: document available fanout policies (2013-08-29 16:43:29 =
-0400)
>=20
> are available in the git repository at:
>=20
>   git://gitorious.org/linux-can/linux-can-next.git for-davem
>=20
> for you to fetch changes up to 391ac1282dd7ff1cb8245cccc5262e8e4173edc4=
:
>=20
>   can: gw: add a per rule limitation of frame hops (2013-08-29 22:58:24=
 +0200)
>=20
> ----------------------------------------------------------------
> Gerhard Sittig (2):
>       can: mscan: add a comment on reg to idx mapping
>       can: mscan: improve clock API use
>=20
> Oliver Hartkopp (1):
>       can: gw: add a per rule limitation of frame hops
>=20
>  drivers/net/can/mscan/mpc5xxx_can.c | 23 ++++++++++++++++-------
>  drivers/net/can/mscan/mscan.c       | 25 ++++++++++++++++++++++++-
>  drivers/net/can/mscan/mscan.h       |  3 +++
>  include/uapi/linux/can/gw.h         |  9 ++++++++-
>  net/can/gw.c                        | 35 +++++++++++++++++++++++++++++=
++----
>  5 files changed, 82 insertions(+), 13 deletions(-)
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--T4CrLkgH3rfKUh3Pr154f85gjdKKPhUgA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIk4aMACgkQjTAFq1RaXHNyJACePAwdlsR21ZAagFtm/gL8I4b9
urIAnjHPqLJ6i8e7QFXFBtYnuAMIUA0o
=LtzB
-----END PGP SIGNATURE-----

--T4CrLkgH3rfKUh3Pr154f85gjdKKPhUgA--
