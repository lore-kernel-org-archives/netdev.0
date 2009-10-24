From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Sat, 24 Oct 2009 21:33:41 +0100
Message-ID: <1256416421.3916.312.camel@localhost>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	 <20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	 <20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	 <20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	 <20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	 <20091018103920.ca9217ee.ken_kawasaki@spring.nifty.jp>
	 <1256152686.8469.34.camel@localhost.localdomain>
	 <20091022201006.1fdfb5cc.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Otp9cNKPqgVvkw1qddaI"
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48186 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752098AbZJXUhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 16:37:17 -0400
In-Reply-To: <20091022201006.1fdfb5cc.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Otp9cNKPqgVvkw1qddaI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-10-22 at 20:47 +0100, Ken Kawasaki wrote:
> Hi,
>=20
> >Dan Williams <dcbw@redhat.com> wrote:
>=20
> > > add cis of PreMax ethernet pcmcia card,
> > > and some Sierra Wireless serial card(AC555, AC7xx, AC8xx).
> =20
> > Random question: are CIS files copyrightable? =20
>=20
> The CIS contains the IRQ, ioport-range, voltage information etc
> like the PCI config space.
> So I think it is not copyrightable.
> but Sierra Wireless provided this CIS by GPL.
[...]

If it is subject to copyright - which apparently they think it is - then
when redistributing under GPL we must be able to provide the 'preferred
form for modification'.  So that leads to the question, is this blob or
hex file the preferred form?

I know very little about CIS but it appears to have a fairly simple
structure that could perhaps be constructed with a hex editor.  However,
if a manufacturer or a later maintainer actually compiles it from a file
in some other format which has extra information like comments or named
constants then I think that should be included in the kernel source.

Ben.

--=20
Ben Hutchings
The obvious mathematical breakthrough [to break modern encryption] would be
development of an easy way to factor large prime numbers. - Bill Gates

--=-Otp9cNKPqgVvkw1qddaI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASuNko+e/yOyVhhEJAQJRGRAAsP3+ggnmvh3irBSVPFoqoAm2IxcMMm/7
eLLH+BiSnhqGjKqr9PURCg8/fmf1qXO7dqcdY9G5DRUf/8c3roLt4Q+IWlDWWV6K
4NESX2iopAZ9pg0pTGN2TmyBe4n/GovvQT13Sb4PYMVMxQtsHn95UdzUTZ2fmGMq
acHyPGrQrzHobvv8RqFbz5JgmsHlq0fzhrfdV9gF2oOlIOBJ2sdAOMEeDt6bFQgm
l76/JrOHL/yEKbvzBwahM74BoKMi6yR9bxOaxV2Gmdm6dC1c7KivUgGLk9Fzpx4p
2X2RJQablYL2OfwrMdEiiNDwXRFkcrr1+XUykzzhIy9YrW1f7pIeU1paJ1S12F8g
8q5+Y7ghKZD2DxdePq3Y2jT2aBT0t37Sg0CVKSYe0wHg/Am7tpYub8aTVd6smAiy
KkDrgq50erwHw0LusUh39srPTaCsa+gx3JE31B83Kk9R/NRHxYHBJ43mlPSRJpZt
diJ3UoIGto3efMXMySwr8xKCm8t9kneYmSuycBkdK3gddg6WC/XWkdqUNk8g77TQ
s00vKoOgxpQP3J8eoeTsUGozrCNkrR2yoL+Dn2/LyEcmQJRhaNgkdgW1F3DKMY+3
n9ST2sMI8ml9Wfs0xj2Fo16p6DgM/8IgC6woFEIhJgUESq8gy3SO6Z3BKSUKCT8A
LUXQQjanYLQ=
=+q0o
-----END PGP SIGNATURE-----

--=-Otp9cNKPqgVvkw1qddaI--
