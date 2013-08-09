From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with regulator
 API
Date: Fri, 09 Aug 2013 09:37:40 +0200
Message-ID: <52049C44.6030902@pengutronix.de>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Uts0NtGbjLgQKrtdpFwbNnPepCDEeld2c"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-arm-kernel@lists.infradead.org,
	Eric Miao <eric.y.miao@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Haojian Zhuang <haojian.zhuang@gmail.com>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1375963227-6468-1-git-send-email-shc_work@mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Uts0NtGbjLgQKrtdpFwbNnPepCDEeld2c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/08/2013 02:00 PM, Alexander Shiyan wrote:
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> ---
>  arch/arm/mach-pxa/icontrol.c         |  3 --
>  arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------

What's pxa's status of DT conversion? Do you (still) accept patches to
board files?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Uts0NtGbjLgQKrtdpFwbNnPepCDEeld2c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIEnEUACgkQjTAFq1RaXHOHEQCgiPytvRcdz3Bnf4OIaMn3umW5
5nMAn3VxdnfFPGrJNSsbYXUG7XVd5M2C
=OCud
-----END PGP SIGNATURE-----

--Uts0NtGbjLgQKrtdpFwbNnPepCDEeld2c--
