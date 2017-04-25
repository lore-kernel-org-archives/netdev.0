From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can 2017-04-25
Date: Tue, 25 Apr 2017 17:33:35 +0200
Message-ID: <d9a6c753-cc92-f31e-47a6-9110040d7294@pengutronix.de>
References: <20170425121645.9946-1-mkl@pengutronix.de>
 <20170425.112126.232541678435322858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="KBQ2hggjWbjaQpN0wcTxBAe5Bi9nrGMah"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:34123 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1950301AbdDYPdu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:33:50 -0400
In-Reply-To: <20170425.112126.232541678435322858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KBQ2hggjWbjaQpN0wcTxBAe5Bi9nrGMah
Content-Type: multipart/mixed; boundary="6IHlAq1Rs730a9fqDukvETcQKoHDuoCVX";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org, kernel@pengutronix.de
Message-ID: <d9a6c753-cc92-f31e-47a6-9110040d7294@pengutronix.de>
Subject: Re: pull-request: can 2017-04-25
References: <20170425121645.9946-1-mkl@pengutronix.de>
 <20170425.112126.232541678435322858.davem@davemloft.net>
In-Reply-To: <20170425.112126.232541678435322858.davem@davemloft.net>

--6IHlAq1Rs730a9fqDukvETcQKoHDuoCVX
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/25/2017 05:21 PM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Tue, 25 Apr 2017 14:16:42 +0200
>=20
>> this is a pull request of three patches for net/master.
>>
>> There are two patches by Stephane Grosjean for that add a new variant =
to the
>> PCAN-Chip USB driver. The other patch is by Maksim Salau, which swtich=
es the
>> memory for USB transfers from heap to stack.
>=20
> I think you meant "from stack to heap", but anyways pulled thanks!

Yes and that's what the patch does.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--6IHlAq1Rs730a9fqDukvETcQKoHDuoCVX--

--KBQ2hggjWbjaQpN0wcTxBAe5Bi9nrGMah
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlj/bE8ACgkQHv7KIOw4
HPa+4ggAjlL79RNjN5SpLt6ACyWILfQhcEC27pcaadpT8Htom/k5X45eqDulV/8S
srTjocUvUbKyU/53TEZ+QrIuI7k9GU3fFCgqevnl9ZPLV0BTCvDUDJuQ0kvHlfdF
iMyDB2Mr2QlrHVg4jGTPJwjmH0WckUTh0by1t0IA5wTRkFT6VC9b1CrO2NWhFzyM
4POsXvCnfkY/VPk3jd8q+VxgnKQWFSYQ4YMzGdZGDD9h96wqHn584ArskYzEvMkT
gSlsdDXn66zwwUo6qAHxdSvYoN/MsRnp2KoMnYl571CQUYQ+odO9aYygXiDjIcMA
YztFNl6TB5kjj4XJPtF7v/AAQjEJ4Q==
=QK/y
-----END PGP SIGNATURE-----

--KBQ2hggjWbjaQpN0wcTxBAe5Bi9nrGMah--
