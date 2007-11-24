From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 14:49:36 +0100
Message-ID: <1195912176.4149.194.camel@johannes.berg>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
	 <1195893216.4149.186.camel@johannes.berg>
	 <20071124133200.GA27531@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-z6mzj2kzrRRV8Bepqh0v"
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071124133200.GA27531-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-z6mzj2kzrRRV8Bepqh0v
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Sat, 2007-11-24 at 21:32 +0800, Herbert Xu wrote:
> On Sat, Nov 24, 2007 at 09:33:36AM +0100, Johannes Berg wrote:
> >
> > We still require four-byte alignment, no?
>=20
> Not at all.  If NET_IP_ALIGN is zero then it won't be four-byte
> aligned (since the Ethernet header is 14 bytes long).

Right. I just didn't think that would be a valid value for an
architecture to set.

johannes

--=-z6mzj2kzrRRV8Bepqh0v
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0gr76Vg1VMiehFYAQKFbQ/8CuwA8tBGbjSffTdl/xRaIUB+7eyoVdtn
wYgbij9M1986+2YTD7BLLyyAbsJUyBuIAPBrTUHnfD8/HKNqFG1pU51xOiSD1vV8
LqR8ZFfoMAE4tD+s8ZcbPao9YA3uZi47kPJcPCggxIgLbN4tQShiURBm0OBs0HOf
ki1HGAMKUAbtxMOy06mhr8jK71QHVMK/7z9AvG4ysNYGNrNc7o8NecxBurXbLM8r
lDd4TdwQoYTxHUHY0syylO0i7t1BT32uTOXUekBx1Nq0uLAzI/fedN8W97C1/4+U
v3hIvz8fNZE2+KsOF6ZtAmePlNeMfJiT1x3TkCKDO0PiPWe9aVBN+fOcmwmKXrsU
AYqyU8OOc7nicnJPnA60h/G/Gxr4Ecc9WzP9/N4nVZXISINM5rknQjqgEXhsHE7K
QizTgTtLcAjcCbz1IxQwtiS87Yrbycj3q7V7mYQhXWCtfo5yeQZmD4mYh7nFVjSg
Av60PzoYmaTbj80iGqOozF9aYbfQEJa2aeJWTC1zCIZ8dwWlmMhrn/cZyQvB016H
lVtwT1YdiP4YlNVtfhUQjqMOqltckhN8PguTTNeymZkc1oggUnx13eSxwFr04h9k
PD+Wf8VUbgrFYmN0xaO4wXlhvEGG0xsyEU+6vXEFxxuhv5dIQBKJLuDGDb5P4NJR
QwIXANxwg4s=
=BJAW
-----END PGP SIGNATURE-----

--=-z6mzj2kzrRRV8Bepqh0v--
