From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 31/33] net: slcan - set name assign type
Date: Thu, 10 Jul 2014 10:51:04 +0200
Message-ID: <53BE53F8.9090405@pengutronix.de>
References: <1404980258-30853-1-git-send-email-teg@jklm.no> <1404980258-30853-32-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="3NThhxWj3tlRBlbxiOJleNhGoA8t3Q9eX"
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org
To: Tom Gundersen <teg@jklm.no>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-32-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3NThhxWj3tlRBlbxiOJleNhGoA8t3Q9eX
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/10/2014 10:17 AM, Tom Gundersen wrote:
> Names are given by the first available SLCAN channel, so order
> of device creation matters.
>=20
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: linux-can@vger.kernel.org

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--3NThhxWj3tlRBlbxiOJleNhGoA8t3Q9eX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlO+U/gACgkQjTAFq1RaXHMpmQCggsNcSP8juogA2SKk/SeMIS24
pswAn1E8kgIno+JcjRvowGfmQlKUXtM5
=eUHW
-----END PGP SIGNATURE-----

--3NThhxWj3tlRBlbxiOJleNhGoA8t3Q9eX--
