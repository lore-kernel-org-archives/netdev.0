From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Sun, 25 Oct 2009 02:13:29 +0000
Message-ID: <1256436809.2510.0.camel@localhost>
References: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-M8WL5Ph3mS0b9IvpLPJ0"
Cc: netdev@vger.kernel.org
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57677 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752489AbZJYCNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 22:13:36 -0400
In-Reply-To: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-M8WL5Ph3mS0b9IvpLPJ0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-10-25 at 11:10 +0900, Ken Kawasaki wrote:
> Hi,
>=20
> >> > Random question: are CIS files copyrightable? =20
> >>=20
> >> The CIS contains the IRQ, ioport-range, voltage information etc
> >> like the PCI config space.
> >> So I think it is not copyrightable.
> >> but Sierra Wireless provided this CIS by GPL.
> >[...]
>=20
> >If it is subject to copyright - which apparently they think it is - then
> >when redistributing under GPL we must be able to provide the 'preferred
> >form for modification'.  So that leads to the question, is this blob or
> >hex file the preferred form?
>=20
>=20
> (1)The CIS contains data only,
>     does not contain the code to be executed.
> (2)Sierra Wireless provided the binary of the CIS only.
> (3)These CIS are stable and does not need to be modified.
> (3)The content of the CIS can be seen by the dump_cis utility.
>=20
> So if someone want to modify the CIS , I think it is OK
> to use hex editor.

That sounds reasonable.  Thanks.

Ben.

--=20
Ben Hutchings
The obvious mathematical breakthrough [to break modern encryption] would be
development of an easy way to factor large prime numbers. - Bill Gates

--=-M8WL5Ph3mS0b9IvpLPJ0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASuO0Pee/yOyVhhEJAQIKwQ//QnWgHowZf3Ai3Dm6IHKIwqyUlfagROKt
S3nzhpa928BhXnHoHEmde0ReeVfa9cayDtRxGPWqSf9BG1n9MCOxa74NQ6PZW/1h
6Y8BU9UAIMKxDmP24/QOS7VjpOQnNk/kmR7839U+i4RhIRg5mhcpgOKQyc2llfyb
zMja3kqamF9UfWB96S+mqId8qLgOI4nGH83ARBy0gvRRaS7tEmPutSyG7gjRsIE5
nQa3g6EW+ZPrq6M1a1Fhq/nftCyCrLAu/vH+HSaQe9kNPDuHIMPlyI83T9YhGQw6
53ShCojbaZUtWEM5Vd417IHQv+vUV//Z+v7dBYLxYOgQo8gUvJZ42OTVguUCgXsL
cUwV75ZFRhc8v81LB4qVzlk8hoju7OYgsfGSTyVFDsr1mAvqoa7NdXQPA/yhpqCq
sSMmqfYF+DUMjt/ctczzi9JsSnLUysGZNlWYOr86I0e0ct2Jt/MdJrmTmkvYBdq+
S2/UmO5zHhoiDNjD4GhqiX3eZ57e4OK4KjtWJAyNmi0uHN4Kb0MOL846NgDmdCbE
HFjcR8IjtJwAzrnLJniJjgqbdVnzrUcOP8F9yoMlJ9lVdeL4KvoLFrFaaD3pTLiE
g5faqU6nHDLTu8t+oMA/2wYRBvEf00+laF0OPpHcrR412OuNdAAQ57V/KakN8Qp7
Psv68XlCqzc=
=xkwB
-----END PGP SIGNATURE-----

--=-M8WL5Ph3mS0b9IvpLPJ0--
