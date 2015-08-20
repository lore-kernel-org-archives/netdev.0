From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: flexcan: demote register output to debug level
Date: Thu, 20 Aug 2015 14:15:30 +0200
Message-ID: <55D5C4E2.2000903@pengutronix.de>
References: <1438960563-17905-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="EeXftRUttQGuSQbfxOl1fhBCX8N1RekHT"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	patchwork-lst@pengutronix.de
To: Lucas Stach <l.stach@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45833 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbbHTMPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 08:15:37 -0400
In-Reply-To: <1438960563-17905-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EeXftRUttQGuSQbfxOl1fhBCX8N1RekHT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 08/07/2015 05:16 PM, Lucas Stach wrote:
> This message isn't really helpful for the general reader of the kernel
> logs, so should not be printed with info level. All other register
> programming outputs in the flexcan driver already use the debug level.
>=20
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Added to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--EeXftRUttQGuSQbfxOl1fhBCX8N1RekHT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV1cTiAAoJEP5prqPJtc/HGYQIAK+f4uGKlxMWrxNHM6MTtFew
RrzoEN/RJjGDPrpZscLB51XpIa7By+vn8rk0qKP83FnIT+q8rJo0UGpAb+tX6hPh
/zPD85twLW3hGkVHYsNSHcZBNjBuPj+TmUfSoukO7ND93MmN+0sZTIn5jr6C5Pdi
nocR2ug6V7Pza7v+rdyNFx8y8irnC3ihAB3FTHoEhy+iKHXgFV7oMTActWUH+XFS
tSA3rQr9YDwvHkoWeOUtJFmBj83QcZAdhTVBHVGZCynwW7JFwv+L+TTYX8FkIoss
gpWSXKJGJFPC3uhc4Op4vFmn6IKzqo4UtqhmZuO9RJvxa2kGseDPn/LGhWKdE3g=
=oxzr
-----END PGP SIGNATURE-----

--EeXftRUttQGuSQbfxOl1fhBCX8N1RekHT--
