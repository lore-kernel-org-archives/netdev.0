From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Tue, 12 Jun 2007 12:01:33 +1000
Message-ID: <1181613693.17771.2.camel@concordia.ozlabs.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
	 <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
	 <20070608170608.GI7904@austin.ibm.com>
	 <20070608172020.GA31089@havoc.gtf.org>
	 <20070611181429.GA4397@austin.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TWh3Voh9p+6TQBL/4GTy"
Cc: Jeff Garzik <jeff@garzik.org>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34035 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754645AbXFLCBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 22:01:37 -0400
In-Reply-To: <20070611181429.GA4397@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-TWh3Voh9p+6TQBL/4GTy
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-06-11 at 13:14 -0500, Linas Vepstas wrote:
> On Fri, Jun 08, 2007 at 01:20:20PM -0400, Jeff Garzik wrote:
> > On Fri, Jun 08, 2007 at 12:06:08PM -0500, Linas Vepstas wrote:
> > > On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
> > > > On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
> > > > >=20
> > > > > The major bug fixes are:=20
> > > > I realise it's late, but shouldn't "major bugfixes" be going into 2=
2 ?
> > > Yeah, I suppose, I admit I've lost track of the process.=20
> >
> > You need to order your bug fixes first in the queue.=20
>=20
> OK, here are the patches, re-ordered. There is a different number
> than last time, as I threw out one, merged one, and got cold feet
> on a third one.  They still pass the tests.
>=20
> The first five patches focus on three serious bugs, fixing crashes or
> hangs.

Nice one.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-TWh3Voh9p+6TQBL/4GTy
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGbf59dSjSd0sB4dIRAva9AKCzKB43oI/HsOMV2j6+xZs6yxEs6QCff3Dj
GN7eE2rzVQp1CpWOn5dXBic=
=Jcds
-----END PGP SIGNATURE-----

--=-TWh3Voh9p+6TQBL/4GTy--

