From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 1/6] can: sja1000: remove unused defines
Date: Fri, 31 Jan 2014 13:35:34 +0100
Message-ID: <52EB9896.1080409@pengutronix.de>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch> <1391164513-11529-2-git-send-email-florian.vaussard@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="xJS0IwHDtwVVCnbGCReK0en4R63GCukP6"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Vaussard <florian.vaussard@epfl.ch>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391164513-11529-2-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xJS0IwHDtwVVCnbGCReK0en4R63GCukP6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/31/2014 11:35 AM, Florian Vaussard wrote:
> Remove unused defines for the OF platform.
>=20
> Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>

I've overlooked in my first review that this patch is touching the
of_platform driver. Please remove the patch, as we want to remove the
driver sooner or later.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--xJS0IwHDtwVVCnbGCReK0en4R63GCukP6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLrmJYACgkQjTAFq1RaXHPfZwCeMHbfrpk/Pmvn3p9iSaB9Yo7Z
6D8AnixweAmBCz4Hvcm9SZ9Cl0/bJI8H
=y0K2
-----END PGP SIGNATURE-----

--xJS0IwHDtwVVCnbGCReK0en4R63GCukP6--
