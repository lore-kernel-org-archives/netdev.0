From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [Cbe-oss-dev] [PATCH 0/18] spidernet driver bug fixes
Date: Fri, 08 Jun 2007 11:12:31 +1000
Message-ID: <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-SXBdRmJxub63maRZgmbH"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33333 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762999AbXFHBMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 21:12:34 -0400
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-SXBdRmJxub63maRZgmbH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
> Jeff, please apply for the 2.6.23 kernel tree.  The pach series
> consists of two major bugfixes, and several bits of cleanup.
>=20
> The major bug fixes are:=20
>=20
> 1) a rare but fatal bug involving "RX ram full" messages,=20
>    which results in a driver deadlock.
>=20
> 2) misconfigured TX interrupts, causing a sever performance
>    degardation for small packets.

I realise it's late, but shouldn't "major bugfixes" be going into 22 ?

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-SXBdRmJxub63maRZgmbH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGaKz/dSjSd0sB4dIRAnx0AKCYuKAanYdyA9oQWDamLwY8DdaLzACgoAOQ
EnKkDB45FvoLpuDrUssC6C4=
=vSDm
-----END PGP SIGNATURE-----

--=-SXBdRmJxub63maRZgmbH--

