From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: fix sparse warning for cgw_list
Date: Mon, 26 Mar 2012 10:19:05 +0200
Message-ID: <4F702679.3090302@pengutronix.de>
References: <1332716750-3455-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFABEA276012CC3FBFCD8544E"
Cc: socketcan@hartkopp.net, davem@davemloft.net,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Baluta <daniel.baluta@gmail.com>
To: dbaluta@ixiacom.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1332716750-3455-1-git-send-email-dbaluta@ixiacom.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFABEA276012CC3FBFCD8544E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/26/2012 01:05 AM, dbaluta@ixiacom.com wrote:
> From: Daniel Baluta <daniel.baluta@gmail.com>
>=20
> Make cgw_list static to remove the following sparse warning:
> net/can/gw.c:69:1: warning: symbol 'cgw_list' was not declared.
> Should it be static?
>=20
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>

Thanks, applied to can-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigFABEA276012CC3FBFCD8544E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk9wJnkACgkQjTAFq1RaXHMWDwCfa/h/A41TirYRFGujPOU8us58
c0UAn3SKaCGfNw9Kizl1DhcbAkjko3Jh
=jxZa
-----END PGP SIGNATURE-----

--------------enigFABEA276012CC3FBFCD8544E--
