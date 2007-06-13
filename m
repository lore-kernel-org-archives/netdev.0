From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Wed, 13 Jun 2007 23:53:18 +1000
Message-ID: <1181742798.12693.14.camel@concordia.ozlabs.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
	 <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
	 <20070608170608.GI7904@austin.ibm.com>
	 <20070608172020.GA31089@havoc.gtf.org>
	 <20070611181429.GA4397@austin.ibm.com>  <466F2581.2080808@garzik.org>
	 <1181698396.6988.5.camel@concordia.ozlabs.ibm.com>
	 <466F4E64.5070303@garzik.org>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-lFsT4GBIi+RVWsu0VXVK"
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35841 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756352AbXFMNx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 09:53:26 -0400
In-Reply-To: <466F4E64.5070303@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lFsT4GBIi+RVWsu0VXVK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-06-12 at 21:54 -0400, Jeff Garzik wrote:
> Michael Ellerman wrote:
> > Linas posted the patches, I responded querying whether the bug fixes
> > should go into 2.6.22, and then you told him "you need to order your bu=
g
> > fixes first in the queue". Which seemed pretty clear to me that you'd
> > wait for the reordered series.
>=20
> This was presuming Linas actually knew what he himself had submitted=20
> previously, and had been accepted...
>=20
> I explicitly emailed Linas on May 24, 2007 detailing each patch that had=20
> been applied, and to which netdev-2.6.git branch it had been applied=20
> (and thus whether it was queued for 2.6.22 or 2.6.23).  Relevant=20
> Message-id is <4656033F.1060505@garzik.org>, and was sent not only to=20
> Linas but also to netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, and=20
> cbe-oss-dev@ozlabs.org.
>=20
> These changes were subsequently made public immediately via=20
> git://git.kernel.org/.../jgarzik/netdev-2.6.git branches=20
> 'upstream-fixes' and 'upstream', and were followed a few days later by=20
> akpm's public tree, starting with 2.6.22-rc3-mm1 (and all subsequent=20
> releases).
>=20
> All of the above seemed pretty clear, too.

Yeah fair enuf, that's fairly clear.

> To move forward, it sounds like the best thing to do is drop all=20
> spidernet patches and start over, yes?

Well see what Linas thinks, but that is probably easiest. I was just
keen to see the "major bugfixes" get into 22, rather than waiting
another few months for 23.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-lFsT4GBIi+RVWsu0VXVK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGb/bOdSjSd0sB4dIRAjDaAJ9GsFUZEwZQ28A4V4nykWZs6iRSLwCeLTtE
qqGxD2NLE8ZAbdqslFxB/Hw=
=iYaF
-----END PGP SIGNATURE-----

--=-lFsT4GBIi+RVWsu0VXVK--

