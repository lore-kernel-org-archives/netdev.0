From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH linux-firmware] tg3: Add EEE support firmware for 57766
 cards
Date: Sat, 09 Mar 2013 16:20:32 +0000
Message-ID: <1362846032.3768.499.camel@deadeye.wl.decadent.org.uk>
References: <1362614845-20738-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PMZ57/1neN7xfJ3zZBxe"
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	David Woodhouse <dwmw2@infradead.org>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50955 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758479Ab3CIQUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 11:20:35 -0500
In-Reply-To: <1362614845-20738-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PMZ57/1neN7xfJ3zZBxe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-03-06 at 16:07 -0800, Nithin Nayak Sujir wrote:
> 57766 devices with no nvram need a service patch firmware for the boot
> code to support EEE. This patch adds the fw.
>=20
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  WHENCE             |   3 ++-
>  tigon/tg357766.bin | Bin 0 -> 144 bytes
>  2 files changed, 2 insertions(+), 1 deletion(-)
>  create mode 100644 tigon/tg357766.bin
[...]

Applied, thanks.

Firmware updates should be sent to my personal address (as above), not
my work address.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.

--=-PMZ57/1neN7xfJ3zZBxe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUTthUOe/yOyVhhEJAQokLg//YCZIdzcb2Hnz9egpz1P0RB7hgB3k1k6h
alTZOcnfygFEc2+ZLnV3QV8vypIqs9DAXaCLSdFMots6xRVmVuyCWvWo4Ygx0sWg
Rk8mJ3la5OisMGcqyXRt95KUckpU3AfIaOJPervmjz+N2TocEcr8Z9siYxaI3gU9
ya8gOHrt4p4nKgy3zvpjZk524SAiHiN/NBXv+RDrPpblulyKw2DqhMuF5dUNhyrM
qzJsuEnQs2Bo5RLtPexlIcHH62VXh6uSi5nDsgltOit288+g/4gVfBPeEoP6LD17
ijb7yoFNcgo3drOdnpCtmbmP+0/E4ObfYG1jCEJ8Gw+tDGw8wTGyVQFZYxKdZpLA
53QqifUhOUZ3JfxewaWZ9vAxS9u+vR9T5+K4NZiY0baOaKGaKKQt2rkC29Ok+E7y
x2SmPH6S1WHmG3nnEywqJOdFfP89FUus9FB2JLWcABiNlQIrgEgogZUHuFfMmlBo
yDyLAt3zX6t/iN59UW0zXxD0XsVH6gpsmeILxVk0C19uQksrEVV5s417iv9XDo7H
iHmAXIgdJ9AcsFUe/I94cVTXZIOLgOZwJOCYAgORGDjKKtT6bGOGpNm7Xa+H3nDB
KGFpkxbcgKYU13729+2CtA2RQIxlsHeTQj7d4kvZVsL2u7cdPLYNIe12NkGGR3ZE
fb8yH6Tom0c=
=PpmN
-----END PGP SIGNATURE-----

--=-PMZ57/1neN7xfJ3zZBxe--
