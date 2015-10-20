From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc
 controller
Date: Tue, 20 Oct 2015 17:20:36 +0200
Message-ID: <56265BC4.8080403@pengutronix.de>
References: <1445236757-29019-1-git-send-email-hs@denx.de>
 <56249491.4020009@pengutronix.de> <56249B58.6090100@denx.de>
 <56249C3F.3080000@pengutronix.de> <56265661.7000509@gmail.com>
 <56265852.6000601@pengutronix.de> <56265947.8050008@gmail.com>
 <56265B55.2070203@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="U4N3LwP0TtCQv4oPeFGde3Nt3bNSuGJ3i"
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?Q?Beno=c3=aet_Cousson?= <bcousson@baylibre.com>,
	Anant Gole <anantgole@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-omap@vger.kernel.org
To: "Anton.Glukhov" <anton.a.glukhov@gmail.com>, hs@denx.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56265B55.2070203@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--U4N3LwP0TtCQv4oPeFGde3Nt3bNSuGJ3i
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/20/2015 05:18 PM, Marc Kleine-Budde wrote:
> On 10/20/2015 05:09 PM, Anton.Glukhov wrote:
>>>> It's OMAP3 based arch, but HECC is implemented only in AM3505 and AM=
3517 SoCs.
>>>> So, I'm confused about what's "name" should I use.
>>>
>>> Which SoC was available first? Pick that.
>=20
>> What do you mean available? I know only that HECC appear in AM3505 and=
 AM3517. Nowhere else.
>=20
> Available on the market. Which one was produced first or was soldered
> first to some PCB?

A colleague just looked it up, a AM3517 is a AM3505 with 3d graphics. So
pick AM3505.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--U4N3LwP0TtCQv4oPeFGde3Nt3bNSuGJ3i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWJlvEAAoJEP5prqPJtc/H1pUH+wU1Ei8QoFxN8lEQ6sFEyjLW
ZSJ3Dhpf8jkSwhi8LkLBo2Sv9yI4/22LNkuiKI8jf7qi3xD6pMPinooIHxaswD1O
/Aw+yWRXq5pjHzSKeDTgIOSWQr4AFp3RvHEMpYap1A2BqcdUsxi/c+0E41VDZOhA
ccDTuXezFcXgKFZhi3dFhfDAIuQxLQ3RuDB7UFFtyY/zMB9nbV49p2JiIaoOJuwX
po8qUu1eJyA2qHdtmw0c1xalti+HqtYkcQGtk2PclBE/wiyoWWuL8zv9lvhXZnG+
kzUXOmezsyBmT9bqeDtb591r0/j4n0R4OGfFtkAGK8OnQTDe+AXzwnumEioYwTs=
=fH6R
-----END PGP SIGNATURE-----

--U4N3LwP0TtCQv4oPeFGde3Nt3bNSuGJ3i--
