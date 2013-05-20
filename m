From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] can: flexcan: Let device core handle pinctrl
Date: Mon, 20 May 2013 18:07:26 +0200
Message-ID: <519A4A3E.1060603@pengutronix.de>
References: <1369055178-6083-1-git-send-email-fabio.estevam@freescale.com> <1369055178-6083-2-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2WMOMBANIUEHKROURLMVW"
Cc: davem@davemloft.net, shawn.guo@linaro.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43080 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756950Ab3ETQHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:07:32 -0400
In-Reply-To: <1369055178-6083-2-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2WMOMBANIUEHKROURLMVW
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/20/2013 03:06 PM, Fabio Estevam wrote:
> Since commit ab78029 (drivers/pinctrl: grab default handles from device=
 core)
> we can rely on device core for handling pinctrl, so remove=20
> devm_pinctrl_get_select_default() from the driver.
>=20
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: <linux-can@vger.kernel.org>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

applied to linux-can-next.

Thx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2WMOMBANIUEHKROURLMVW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGaSj4ACgkQjTAFq1RaXHNS/QCggw2i9S28cQ+ig6dS3LKWJ/9d
DG8AoJDAgjYOYCveMf6MfT6sBEetbDJK
=nIDi
-----END PGP SIGNATURE-----

------enig2WMOMBANIUEHKROURLMVW--
