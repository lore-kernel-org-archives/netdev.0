From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 3/7] can: m_can: add .ndo_change_mtu function
Date: Mon, 03 Nov 2014 17:49:47 +0100
Message-ID: <5457B22B.1010905@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-3-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Iu16gDTdVrDphOLcFA0xO5WMNsiRwNgkQ"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1414579527-31100-3-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Iu16gDTdVrDphOLcFA0xO5WMNsiRwNgkQ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> Use common can_change_mtu function.
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>

Applied to can/master.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Iu16gDTdVrDphOLcFA0xO5WMNsiRwNgkQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV7IrAAoJECte4hHFiupUuMQQAITkM0b8Ld9swExIznHOVzH0
iy+4Dhp1xZZ4OgsChigPAU43J+0BjPHid9LuRInJrzCs+U/7qPw5GG+lNm7ZBLh0
EOzBCrgsYnzUb97oynOaHONl4hOBZKnsgPDAN4Ea77ypnAcswxgNsEt0pCg+yRMJ
nWirKRa5kch3kJBTorNaeoydygQWpT5RS+XX8S9nIzAre2OfwF2CLp3YFLGsqRwz
P00Y2w9uIhGN/lbM+AQ2LBUL+YpQR43xwbOzaVzVMdEewH7fOhw8pplW2emoUqxU
1EsSus/nkXUP/W+gf2eJmrvLygfMGmeLoWRCotLZcQJ5f9DuWBlgzzeN+UReGmky
Nm75qXIwWRdPerUJ+U+Ueiok4At3hazKtpLA6Pf0xE/E/GOVrf4xRsAAjE5rQukq
uT1EqF8GZghCGUdO3+k/iwYdR+NUlChAejHpl9CPD3xkvstkWj1dGq9Gsop3gT2Z
hOb33Di1KqhcxklNNZokgvWvb0recYlF39DcozvzNid6cJ4+gaM0JjFg2ksIdfAE
YhIkBR0CF5utXAo6nkVqkU1Vxto7Sec0JNxheLNkfvdENfbP/v8lKq1jK869H9Gc
oaSby1BssNO/cpWqL/u0bGFJTbl3SiXGKMR2B5eI9ZWdQ/IBL0feuYzWO56wYMdy
ujNMDPXvVyd7506dOImQ
=furR
-----END PGP SIGNATURE-----

--Iu16gDTdVrDphOLcFA0xO5WMNsiRwNgkQ--
