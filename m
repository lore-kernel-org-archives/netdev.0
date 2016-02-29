From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] can: rcar_can: Add r8a7795 support
Date: Mon, 29 Feb 2016 11:02:22 +0100
Message-ID: <56D4172E.4050407@pengutronix.de>
References: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1456737661-20538-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D411A5.9070706@pengutronix.de>
 <SG2PR06MB10380FC567E038EA92D5401EC3BA0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="91c4EuRkOnW0mIoP9axSHeADILd2MUGcP"
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB10380FC567E038EA92D5401EC3BA0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--91c4EuRkOnW0mIoP9axSHeADILd2MUGcP
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/29/2016 10:56 AM, Ramesh Shanmugasundaram wrote:
> root@salvator-x:~# can-calc-bit-timing -c 39999998 rcar_can =20

Can you send me the patches to support the rcar_can. On the linux-can ML
or github pull request.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--91c4EuRkOnW0mIoP9axSHeADILd2MUGcP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW1BcuAAoJED07qiWsqSVqZLoH/0b812uFBjQenKKxA6LeTN20
z7pev5rXBYS8uBd1/RJ5aAZRqnEmEIoVKxSOa1PPRYLTqoUog5Ev9QlS+UQdVdBr
tw5jPlI7btvT7NraWA7ZaOFIVCp6lvpPC7dfY4JX5oXvcLmRLEOUP0KAP9rSgupw
RjKxTSuAPk5uRuv8nI9ua85cCMhLu+ojjx4SGY2hWVP/6VkGiMc/agBfhfzHDX6G
S822ZTTKwRSpCHx8jimyhHAz6aLDYVdbKWwaV+M/V9K6Cpo4y1bp2c6GSmgZr52R
mycX8naTomBCsMG7pvTyQp3uGuAzdy4h1VTErXH/yKxwzAwAsgg25Mb9K9jXM7o=
=ahJr
-----END PGP SIGNATURE-----

--91c4EuRkOnW0mIoP9axSHeADILd2MUGcP--
