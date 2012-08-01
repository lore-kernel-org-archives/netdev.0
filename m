From: Noah Meyerhans <frodo@morgul.net>
Subject: Re: iputils git tree
Date: Tue, 31 Jul 2012 21:09:57 -0700
Message-ID: <20120801040957.GL11095@morgul.net>
References: <201203182107.43855.vapier@gentoo.org>
 <20120801024656.GK11095@morgul.net>
 <20120731.202918.621064199466580610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="47eKBCiAZYFK5l32"
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, vapier@gentoo.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.morgul.net ([128.31.0.48]:55167 "EHLO minas.morgul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814Ab2HAEKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 00:10:00 -0400
Content-Disposition: inline
In-Reply-To: <20120731.202918.621064199466580610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--47eKBCiAZYFK5l32
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 31, 2012 at 08:29:18PM -0700, David Miller wrote:
> iputils has been unmaintained for at least 2 years.
>=20
> Someone needs to step up and take over maintainence of it.
>=20
> Otherwise, expect the current situation to continue.

I was under the impresion that iputils had been handed over from Alexey
to Hideaki YOSHIFUJI.  The fork at linux-ipv6.org certainly doesn't
appear dead.  I count 12 commits this year to the repository visible at
http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=3Dgitroot/iputils.git;a=3Dsum=
mary
It's not exactly a screaming fast pace, but it's something.

There are several (mostly relatively minor) bugs that have been fixed in
the Debian packages (of which I'm the maintainer). There's another
assortment of patches in the Debian bug tracker that haven't yet been
merged in.  I imagine Fedora and RHEL have a collection of similar
modifications. So I suspect that iputils really isn't dead, but it's
just that nobody's bothering to push changes back upstream. I'm more
than happy to start doing so.

noah


--47eKBCiAZYFK5l32
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFQGKwVYrVLjBFATsMRAhRqAJ4oAM8cq7cNafgakyGFL8SGH20dZACeIWWR
49q4As0ipcbhBfn7I+LRAMQ=
=hjO+
-----END PGP SIGNATURE-----

--47eKBCiAZYFK5l32--
