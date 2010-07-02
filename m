From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-2.6 2/2] usbnet: Set parent device early for
 netdev_printk()
Date: Fri, 02 Jul 2010 23:56:26 +0100
Message-ID: <1278111386.4878.77.camel@localhost>
References: <1278110361.4878.73.camel@localhost>
	 <1278110450.4878.75.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-qGm15R6nlkPEyXKUFR7j"
Cc: netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Lu=EDs?= Picciochi Oliveira <pitxyoki@gmail.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56049 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753336Ab0GBW4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 18:56:32 -0400
In-Reply-To: <1278110450.4878.75.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qGm15R6nlkPEyXKUFR7j
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-07-02 at 23:40 +0100, Ben Hutchings wrote:
> netdev_printk() follows the net_device's parent device pointer, so
> we must set that earlier than we previously did.
>=20
> Reported-by: Lu=C3=ADs Picciochi Oliveira <pitxyoki@gmail.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
[...]

This should also go into a stable update for 2.6.34.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-qGm15R6nlkPEyXKUFR7j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATC5uhOe/yOyVhhEJAQI2yg//dh93RyzRbj4Ntyip4ap/wfXu187N0V3p
Gly4u9P/5dqSXdvjsb3U1ah+X2/F6a2sDoRWKqtnTwP4jZSc7NkE3/7iocrKUc5e
IMTlZ3JFNXcJgybCfK7YQCh1tMp9yuHLCnYsybvbZf6NxKe8cCWCR1a6NyDoofa5
BYbl3GqIRyVBrqF9z1HOx9nifE3I8GvCtiqWZCG2gPVEJbyvEL/pBGxLF7R5ZQTK
mwUPadWZ97l1r+GYc+IEUqpPL62nEfCOQWoU26dpKM7JgYiPONtso86xA6Iommnt
ZdljztHRHf1eEqcS2SJSKikSCZP2q4K6mgsvN0m5aJRk3W5aNojvwYgVk2Wd94sv
gHRXA9Az5p4or0WZWqdoJdFcy5qDOT5yBpcDb71Oq2h4ZUwFmkUv23esiRUcwVQz
C5f7BFqvH/r1oC+JLyRgZEp38QFDRPDDZ4XObC4Y11J8bYGV6TUcW7g3+MJWtFf9
u1sYLNgODcGg/9H0Vw9zJ948ko0KKM9qrXAwrAzdCJQUoFZwkb6oG8OulQ/lqmTS
cjGF48aAtvZ3DQklTyBaOi8M4FUUBSVRp4tMqyk0ccQRlnoltf/CDSkadx5K4JrL
eZn9jrz4rQgy45dyz/HRALPxGHifAJNb1sAjl3e1lQBKzYhSO49pPrnYBPbDvg4H
AvvUZ+ubzXM=
=9W6L
-----END PGP SIGNATURE-----

--=-qGm15R6nlkPEyXKUFR7j--
