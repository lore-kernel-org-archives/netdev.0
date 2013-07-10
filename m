From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 07/12] drivers/net/can/c_can: don't use devm_pinctrl_get_select_default()
 in probe
Date: Wed, 10 Jul 2013 23:02:57 +0200
Message-ID: <51DDCC01.1090104@pengutronix.de>
References: <1373471889-18107-1-git-send-email-wsa@the-dreams.de> <1373471889-18107-7-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2GEBQRHRHUWQHPQCAISEH"
Cc: linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	AnilKumar Ch <anilkumar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>,
	Jingoo Han <jg1.han@samsung.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1373471889-18107-7-git-send-email-wsa@the-dreams.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2GEBQRHRHUWQHPQCAISEH
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/10/2013 05:57 PM, Wolfram Sang wrote:
> Since commit ab78029 (drivers/pinctrl: grab default handles from device=
 core),
> we can rely on device core for setting the default pins. Compile tested=
 only.
>=20
> Acked-by: Linus Walleij <linus.walleij@linaro.org> (personally at LCE13=
)
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Who takes care of this patch/patch series?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2GEBQRHRHUWQHPQCAISEH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlHdzAEACgkQjTAFq1RaXHNxuwCfU22mQey9fGPWB0I1SWFaBJ7x
M70AnR9WXSzupvQ4/lraplY5fhqhJXl6
=7O5d
-----END PGP SIGNATURE-----

------enig2GEBQRHRHUWQHPQCAISEH--
