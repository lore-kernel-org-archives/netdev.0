From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: sfc: Replace LRO with GRO
Date: Tue, 20 Jan 2009 11:57:01 +1100
Message-ID: <20090120115701.a273f3b9.sfr@canb.auug.org.au>
References: <20090115042422.GB29658@gondor.apana.org.au>
	<20090118.215027.46669769.davem@davemloft.net>
	<1232376006.3004.19.camel@achroite>
	<20090119.132929.108799868.davem@davemloft.net>
	<1232403167.5539.1.camel@brick>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__20_Jan_2009_11_57_01_+1100_PjlUNPJcYwKhofu4"
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:36066 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756952AbZATA5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 19:57:20 -0500
In-Reply-To: <1232403167.5539.1.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__20_Jan_2009_11_57_01_+1100_PjlUNPJcYwKhofu4
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, 19 Jan 2009 14:12:47 -0800 Harvey Harrison <harvey.harrison@gmail.c=
om> wrote:
>
> On Mon, 2009-01-19 at 13:29 -0800, David Miller wrote:
> >=20
> > I haven't published my net-next-2.6 tree at all, because
> > Stephen Rothwell hasn't stated that such content is
> > OK yet for his -next tree.
>=20
> I thought Stephen had stated that anytime _after_ -rc1 was released was
> OK for new material destined for the next release.
>=20
> If you're waiting for an explicit OK, I don't think it will forthcoming.

Here it is: "OK".  :-)

Yeah any time after -rc1 is fine.  I thought -rc2 would be better, but
Andrew beat me into submission :-)  (I suspect he suffers more from that
decision then I do).

It also has the advantage of ruining LCA for you all. :-)
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__20_Jan_2009_11_57_01_+1100_PjlUNPJcYwKhofu4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkl1IV0ACgkQjjKRsyhoI8x42gCgpcj+qeN/WKNd25h0vitQ3KIT
zPYAn1mL6hXGOasz0qWnmP1nY//pquqI
=jYbZ
-----END PGP SIGNATURE-----

--Signature=_Tue__20_Jan_2009_11_57_01_+1100_PjlUNPJcYwKhofu4--
