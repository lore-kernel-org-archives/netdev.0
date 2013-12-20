From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: ti_hecc: Use the OMAP2PLUS dependency for omap2plus
 devices
Date: Fri, 20 Dec 2013 13:35:58 +0100
Message-ID: <52B439AE.7020304@pengutronix.de>
References: <1387542110-26596-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="jDotSCWA8JkAU7fDF0cVIU963eU2mtfaV"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1387542110-26596-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--jDotSCWA8JkAU7fDF0cVIU963eU2mtfaV
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/20/2013 01:21 PM, Ezequiel Garcia wrote:
> OMAP's ti_hecc driver is used to support the CAN controller on many
> omap2plus SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x).
> Constrain the driver to OMAP2PLUS, which is the super-set of all the
> other SoCs variants.

Why not enable it for all ARM platforms to get a bigger compile coverage?=


Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--jDotSCWA8JkAU7fDF0cVIU963eU2mtfaV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlK0Oa4ACgkQjTAFq1RaXHOC2wCdHlPYM4f8OKWxKo3p5CVzlMSA
kq4AnjHQj4ShfvtRJxWLFhcijQloPlVB
=gz9N
-----END PGP SIGNATURE-----

--jDotSCWA8JkAU7fDF0cVIU963eU2mtfaV--
