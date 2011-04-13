From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: mscan: fix build breakage in mpc5xxx_can
Date: Wed, 13 Apr 2011 12:47:49 +0200
Message-ID: <4DA57F55.7080304@pengutronix.de>
References: <1302688168-26862-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1FC4FC939380C75D51C500B3"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39843 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757885Ab1DMKr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 06:47:56 -0400
In-Reply-To: <1302688168-26862-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1FC4FC939380C75D51C500B3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/13/2011 11:49 AM, Anatolij Gustschin wrote:
> Commit 74888760d40b3ac9054f9c5fa07b566c0676ba2d
> "dt/net: Eliminate users of of_platform_{,un}register_driver"
> broke building mscan driver. Fix it.
>=20
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig1FC4FC939380C75D51C500B3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2lf1oACgkQjTAFq1RaXHMSGACfQ6CjFod4cHy9Jbz4DsxKlQfN
Kv8An205eZH8InNrzCDxEpFob9X/9s3K
=A0HW
-----END PGP SIGNATURE-----

--------------enig1FC4FC939380C75D51C500B3--
