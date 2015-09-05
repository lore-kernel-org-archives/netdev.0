From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: Dump eeprom info for soldered on modules
Date: Sat, 05 Sep 2015 11:48:55 +0100
Message-ID: <1441450135.14803.6.camel@decadent.org.uk>
References: <1439690718-10040-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-R/gLZhLHYnI27m3C0UAL"
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47133 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbbIETNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 15:13:16 -0400
In-Reply-To: <1439690718-10040-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-R/gLZhLHYnI27m3C0UAL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-08-16 at 04:05 +0200, Andrew Lunn wrote:
> Modules which are soldered onto the motherboard may also use the=20
> sff8079
> EEPROM format. Dump these in the same way as SFP modules.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[...]

Applied, thanks.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.


--=-R/gLZhLHYnI27m3C0UAL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVerIl+e/yOyVhhEJAQpLbw//Ug0qLQDk/RaWs3MyXN4ocsInr/27tJY/
fhdtAg58gGjsSk9nVZ0XW0/qc6W2vmE7y42IDBLEvgzoYKCcDUvxa9ecxS55cE7+
IkM2Tj4QKwwlSpfGY/rYnJZI+qFeh6hOxkmM4a6UgzDyLwfUCTqX1ILgxO90XvLG
JPKU3Oy2+u3G52unz0YcJ4ll4Lm8bfmn3PVvI/HmmTzUx+fSoprIH3WtJaeL3rUc
sT6FE0d/ZyqSyI1buWzVMTvJG4rwDG3kaQw40I8Gy42Oc18CrcdNxoO7KoY60mFj
7ySxIYLO5zMt28c2KeE0D4tFeqJp/LmK2+k+IezOcIEIZeK53NCq9VAi+MSaMI4P
fvZsuTXVFHm9d58Hr/Va62a0/dZSZqKEqdvC1Nqsr4ycEGcizJBjkYAPP3GndDcI
4fiyVSxr/4sdsUwYKedSen/QcTtLDR5fUPKdkahOAPp+Nf/V11ZzRUYJiasQ2hJR
UZ6+x6KTnHTUg4TXJqXLREKYZ7qkncEX/7iZp+A+WEUM1SfJFF5Zd8cq09hPfsm2
RE/UPsuI2ngY/dE2qyGvP5ytkmxrXg8O1/fnoV+WBHvo2Aon4K5CZVBkHunt8rV/
tdGTXUSg7015wbNDay+VZminumbqfA7VTEp51NB6K6TvGRcYdngCnAdx1Dwh2pwA
B29B22aMleY=
=eKTQ
-----END PGP SIGNATURE-----

--=-R/gLZhLHYnI27m3C0UAL--
