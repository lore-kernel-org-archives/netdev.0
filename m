From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] add a `make dist` helper
Date: Mon, 17 Dec 2012 08:13:21 -0800
Message-ID: <20121217081321.3392ab02@nehalam.linuxnetplumber.net>
References: <drbl5w8utpw8p960mxvy37j1.1355469370120@email.android.com>
	<20121214090935.7d1706fd@nehalam.linuxnetplumber.net>
	<201212161657.15449.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/DMZFFuK4ks87Jrxbk9AyIBn"; protocol="application/pgp-signature"
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52188 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179Ab2LQQOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 11:14:38 -0500
In-Reply-To: <201212161657.15449.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/DMZFFuK4ks87Jrxbk9AyIBn
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 16 Dec 2012 16:57:14 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> On Friday 14 December 2012 12:09:35 Stephen Hemminger wrote:
> > On Thu, 13 Dec 2012 23:16:10 -0800 Stephen Hemminger wrote:
> > > I appreciate the effort but there are a number of more steps to doing=
 a
> > > release and I need to script them all together.
>=20
> np
>=20
> > The tarball's have been rebased, and I built a iproute2-release script =
for
> > next time.
>=20
> commit it to the tree ? :)
> -mike

It has to many things that are unique to kernel.org and the package.
Plus at this time it only works for me

--Sig_/DMZFFuK4ks87Jrxbk9AyIBn
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQz0ShAAoJEICnf2CVzeR+M1UP/25kCDAgOhvb6+fcBd/95JI4
7JNOFNINE+33crBx4z+YlcsITex0c1OVt253iUvnRNs/P1uzDkluRBKyzWcrkbjD
Re6bgMx8Iif+bm/R5/KVsVQBuFfShFNmrzaCRAUXZEsvpdzPPUScnFZ0FaeEsZoG
RZtmSB+XXuyztw4CifybVlfLOmKekmkbrIX4Nzif8f5gWb1wYxY1+JBl2kxUoj4Z
voXxqAin+SOjlSDsRXm285lMXUcaGKHyjKENte30vmchqKUB5/rUp7nG3SYt3kKP
nHRN2SQcsOaah+CSdBZUmFYjY3x6lwdKJgy5uwCgtyN1Qj/TY6x8Ai0FkCUMGluM
qp10khmpBZ+yKi3VXg5/j1N5dCq2Yphi4ts5hSoVuqrMMeGAkkhSmDVHnYXPx2H2
ru3YjH2JTbeCm3dE+MCClDFlFuhMoHZA+2s0BgJISlAO2wO63EhiyBiv4ScNe5dj
wGV7UbXIhQjJPW1+TzNl479ne15sdBnz/h9SpVO8fzlS5JlJiIuQQWZM8fY/YEDh
SYSf+Z6IF4yA3xy8ewLKoBNGiqnWD3jditnxNlmIa1McqXcyTw3fQLMXaRjdwbbg
etcz+jPOQtbaIMzYSg0NNiwKn02Vsc77ammHKNx6P8zT/cyoC3p+2Qvrk7GqQSWZ
ygpzAYACsE5VFcwr9i0S
=Zv8M
-----END PGP SIGNATURE-----

--Sig_/DMZFFuK4ks87Jrxbk9AyIBn--
