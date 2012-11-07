From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 02/10] arm: at91: move platfarm_data to include/linux/platform_data/atmel.h
Date: Wed, 07 Nov 2012 13:20:41 +0100
Message-ID: <509A5219.2080408@pengutronix.de>
References: <20121107111235.GH20063@game.jcrosoft.org> <1352287374-25176-1-git-send-email-plagnioj@jcrosoft.com> <1352287374-25176-2-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig35807B8655F8528925E7C0C9"
Cc: linux-arm-kernel@lists.infradead.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-ide@vger.kernel.org, linux-input@vger.kernel.org,
	linux-mmc@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	rtc-linux@googlegroups.com,
	spi-devel-general@lists.sourceforge.net,
	linux-serial@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-fbdev@vger.kernel.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1352287374-25176-2-git-send-email-plagnioj@jcrosoft.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig35807B8655F8528925E7C0C9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/07/2012 12:22 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>=

> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: linux-ide@vger.kernel.org
> Cc: linux-input@vger.kernel.org
> Cc: linux-mmc@vger.kernel.org
> Cc: linux-can@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: linux-pcmcia@lists.infradead.org
> Cc: rtc-linux@googlegroups.com
> Cc: spi-devel-general@lists.sourceforge.net
> Cc: linux-serial@vger.kernel.org
> Cc: linux-usb@vger.kernel.org
> Cc: linux-fbdev@vger.kernel.org
> ---
> HI all,
>=20
> 	If it's ok with everyone this will go via at91
> 	with the patch serie than clean up the include/mach

Fine with me.

> 	For preparation to switch to arm multiarch kernel

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de> (for the CAN related cha=
nges)

Marc


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig35807B8655F8528925E7C0C9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlCaUhwACgkQjTAFq1RaXHPpxACghbRDxGsYGS6OC3LEGKKRMvVE
P6cAn1B3NTtB3CmBscGxjMuHx42LmYYR
=omqt
-----END PGP SIGNATURE-----

--------------enig35807B8655F8528925E7C0C9--
