From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v7 1/3] can: Allwinner A10/A20 CAN Controller support -
 Devicetree bindings
Date: Tue, 15 Sep 2015 09:54:00 +0200
Message-ID: <20150915075400.GK4684@lukather>
References: <1442272632-20251-1-git-send-email-info@gerhard-bertelsmann.de>
 <1442272632-20251-2-git-send-email-info@gerhard-bertelsmann.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="j3zO+32zXj6UcJCE"
Cc: wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442272632-20251-2-git-send-email-info@gerhard-bertelsmann.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--j3zO+32zXj6UcJCE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Sep 15, 2015 at 01:17:10AM +0200, Gerhard Bertelsmann wrote:
> Devicetree bindings for Allwinner A10/A20 CAN
>=20
> Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
> ---
>=20
>  .../devicetree/bindings/net/can/sun4i_can.txt      |  38 +
>  1 file changed, 38 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/sun4i_can.txt b/Do=
cumentation/devicetree/bindings/net/can/sun4i_can.txt
> new file mode 100644
> index 0000000..5819043
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/sun4i_can.txt
> @@ -0,0 +1,38 @@
> +Allwinner A10/A20 CAN controller Device Tree Bindings
> +-----------------------------------------------------
> +
> +Required properties:
> +- compatible: "allwinner,sun4ican"

A bit better, but still not the one I told you to use.

Thanks,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--j3zO+32zXj6UcJCE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV986YAAoJEBx+YmzsjxAgNI4P/RnoJjpcHECs2Z4R6zIx+2Jd
1rmMVUeHsgYDajvic35jMKLj68kYptpTeu05JKA4YINHbBb4kkZEVikfF+urSv5p
D56R8T19z6aLVi+myYaHjhJ3zhBemEBEyxHqrw4dEPBaZt+Y401YN42DB+gdcXce
oWAh83whlhwDv/RpAtxRS5piBTIW5UMojSe7LmseWyLupGUfFY61QR4njK93gm1T
oaxpWWlJ6mETR+oAwpiRfVYbF1an0lH51rfJg589eE+slYcBwVw+QS9QG3cS2rmm
m+k4OW2KTtAtb2KW1qynNkelQCDP0XnwSauHq3x2uYVfcP+urMADH8mpMi0PtWye
uerrmU3YlX1f0TOfzwcBi7BVjrsi9rONzX5h7bW6O3Aaenwo/Ubjx5l7dyIW2Skf
IjBnxe5Ks8kljf5wgZCYNmwgbnDwkbiqP8DWQZr3RHvTdYUYQJxQdPtnxrHobZ7R
g6VAYFuAsHdaiHm3skoLkxb54ijKcUEnQ5g125/xPszlBWuOFBQwlZ5jxEPaXtpB
wKhwGYMI2FwGEwBtKAtAa/JsW8d1gkj/g3UY7t4f/GqqO5jcHcVc+HmFoq0tQlkA
3ZI1EcXUI8fl86oETD884Lri33lNMGNbTb259Ru2tprHp1Z+YYYsZi+sYXsZ7KsP
K0biO2AoCuBvQJ0gTbRV
=uobk
-----END PGP SIGNATURE-----

--j3zO+32zXj6UcJCE--
