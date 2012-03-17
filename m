From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] drivers: net: Remove unnecessary line continuations
Date: Sat, 17 Mar 2012 20:21:37 +0100
Message-ID: <4F64E441.1010806@pengutronix.de>
References: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com> <67ad900b6f6451b5b28b004def471c9a41b1ee24.1332011552.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC13B6932E2237BCE0BF9A2C1"
Cc: Geoff Levand <geoff@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <67ad900b6f6451b5b28b004def471c9a41b1ee24.1332011552.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC13B6932E2237BCE0BF9A2C1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/17/2012 08:14 PM, Joe Perches wrote:
> Line continuations are error prone so just remove them.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/can/usb/peak_usb/pcan_usb_pro.c  |    4 ++--
>  drivers/net/ethernet/micrel/ks8695net.c      |    4 ++--
>  drivers/net/ethernet/toshiba/ps3_gelic_net.c |    3 +--
>  drivers/net/ethernet/toshiba/spider_net.c    |    4 ++--
>  drivers/net/irda/bfin_sir.c                  |    4 ++--
>  drivers/net/phy/et1011c.c                    |    9 +++++----
>  6 files changed, 14 insertions(+), 14 deletions(-)

For the peak_usb:
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC13B6932E2237BCE0BF9A2C1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk9k5EYACgkQjTAFq1RaXHNvqACfcA8xYJdhqLIJuZ9UNECRiD6P
AdcAoJS+B5nTjsu/VOTdaegOYL8PeJJt
=QmIL
-----END PGP SIGNATURE-----

--------------enigC13B6932E2237BCE0BF9A2C1--
