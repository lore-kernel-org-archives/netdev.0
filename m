From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: mcp251x: Replace power callbacks with regulator
 API
Date: Thu, 08 Aug 2013 13:53:44 +0200
Message-ID: <520386C8.3020505@pengutronix.de>
References: <1375962183-6229-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="L5wcx4eSDDBsDTSR9UontSEOlevK9vDKj"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1375962183-6229-1-git-send-email-shc_work@mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--L5wcx4eSDDBsDTSR9UontSEOlevK9vDKj
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/08/2013 01:43 PM, Alexander Shiyan wrote:
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> ---
>  arch/arm/mach-pxa/icontrol.c         |  3 --
>  arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------

Can you add alkml on Cc and check if the pxa people (still) accept
patches for board files. The overall idea to use the regulator
frameowork is good.

I'll have a deeper look at the patch later.
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--L5wcx4eSDDBsDTSR9UontSEOlevK9vDKj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIDhskACgkQjTAFq1RaXHP7JgCeN1bWveTIE2pMFUhNWmlc2n21
o+cAn3eOse6WpHkuapCbkb+cBNq9tpo8
=1DaT
-----END PGP SIGNATURE-----

--L5wcx4eSDDBsDTSR9UontSEOlevK9vDKj--
