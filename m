From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [6/6]: jenkins hash for neigh / Statistics
Date: Tue, 28 Sep 2004 19:06:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928170644.GL29961@sunbeam.de.gnumonks.org>
References: <20040925005623.2faf8faf.davem@davemloft.net> <E1CBu70-00010X-00@gondolin.me.apana.org.au> <20040927121403.767e2308.davem@davemloft.net> <20040927222613.GE3236@sunbeam.de.gnumonks.org> <20040927160636.7741d973.davem@davemloft.net> <1096327658.1729.19.camel@localhost.localdomain> <16729.9326.93269.422940@robur.slu.se> <1096388857.21799.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qse+WBH4guesipZ+"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <1096388857.21799.5.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--qse+WBH4guesipZ+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

=20
> I have the newer rtstat/ctstat queued for inclusion this week unless
> Harald get's his newer one done sooner (hint, hint)

well, the new version currently provides backwards compatibility for the
old commands, but it doesn't support old kernels... I'll see how I can
integrate that.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--qse+WBH4guesipZ+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBWZokXaXGVTD0i/8RAvbBAJ9b2KR+CJ12RHX6LG+oOF2a5XAluwCgiBau
rzwkovKFFNyXFq1iDGhFtus=
=JRPQ
-----END PGP SIGNATURE-----

--qse+WBH4guesipZ+--
