From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc
 controller
Date: Tue, 20 Oct 2015 17:18:45 +0200
Message-ID: <56265B55.2070203@pengutronix.de>
References: <1445236757-29019-1-git-send-email-hs@denx.de>
 <56249491.4020009@pengutronix.de> <56249B58.6090100@denx.de>
 <56249C3F.3080000@pengutronix.de> <56265661.7000509@gmail.com>
 <56265852.6000601@pengutronix.de> <56265947.8050008@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="0p5BFP2G1KLliXVdbUEA1pKkEuc5aIFoO"
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?Q?Beno=c3=aet_Cousson?= <bcousson@baylibre.com>,
	Anant Gole <anantgole@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-omap@vger.kernel.org
To: "Anton.Glukhov" <anton.a.glukhov@gmail.com>, hs@denx.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56265947.8050008@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0p5BFP2G1KLliXVdbUEA1pKkEuc5aIFoO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/20/2015 05:09 PM, Anton.Glukhov wrote:
>>> It's OMAP3 based arch, but HECC is implemented only in AM3505 and AM3=
517 SoCs.
>>> So, I'm confused about what's "name" should I use.
>>
>> Which SoC was available first? Pick that.

> What do you mean available? I know only that HECC appear in AM3505 and =
AM3517. Nowhere else.

Available on the market. Which one was produced first or was soldered
first to some PCB?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--0p5BFP2G1KLliXVdbUEA1pKkEuc5aIFoO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWJltVAAoJEP5prqPJtc/H7DcH/1zE/JpjelxrgBicavhI+dGS
8itX0v3ckRHDjSRvTYxtWIbvIKFksJe9ubg/6zMiM2qqD96ovYL87kQVrXroHOGP
5Rr2qGY60dDuXSmtt7yzLpEBpcKBEgFzqNOCCaOVgaSlGzng8As5rlrsfQrmWxXO
1d01m5kenxlIPEurephH8hhrGWT83qOq9yarn5ZF3PqMhT7UOezB5M/+o+XOxNep
YgI8oYnw/htSEQQA86AVGOG141NVSfvKeTbzncFaAvWOyjebgF/GaXpf2M/6hrMT
+3fk88QWpBJ13UsPyNnME5Geo0yMVBE11iEmP3VL/b/sRMJAMQnb7aertAx/JHY=
=p839
-----END PGP SIGNATURE-----

--0p5BFP2G1KLliXVdbUEA1pKkEuc5aIFoO--
