From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [spi-devel-general] [PATCH v2 net-next-2.6] can: Driver for
	the Microchip MCP251x SPI CAN controllers
Date: Mon, 2 Nov 2009 16:25:37 +0100
Message-ID: <20091102152537.GF4696@pengutronix.de>
References: <4AED5589.3090106@grandegger.com>
	<1257174961-28406-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0100330770=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1257174961-28406-1-git-send-email-chripell-VaTbYqLCNhc@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============0100330770==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ulDeV4rPMk/y39in"
Content-Disposition: inline


--ulDeV4rPMk/y39in
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 02, 2009 at 04:16:01PM +0100, Christian Pellegrin wrote:
> ---
>  drivers/net/can/Kconfig              |    6 +
>  drivers/net/can/Makefile             |    1 +
>  drivers/net/can/mcp251x.c            | 1164 ++++++++++++++++++++++++++++=
++++++
>  include/linux/can/platform/mcp251x.h |   36 +
>  4 files changed, 1207 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/mcp251x.c
>  create mode 100644 include/linux/can/platform/mcp251x.h
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 26d77cc..b819cc2 100644

We'd need your Signed-off, please.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--ulDeV4rPMk/y39in
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkru+fEACgkQD27XaX1/VRvblACfRIrm2rKU9LyorM0Bb5LvOp/W
q2wAn1j+95K9YFoGWcd7YLQVIzs7DVxJ
=iYTM
-----END PGP SIGNATURE-----

--ulDeV4rPMk/y39in--

--===============0100330770==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0100330770==--
