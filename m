From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.6] Add NAPI support to sungem.c
Date: Tue, 14 Sep 2004 22:02:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914200238.GM8434@sunbeam.de.gnumonks.org>
References: <20040914153537.GE8434@sunbeam.de.gnumonks.org> <20040914124315.716e9c68.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aRzsUE0Mp86t8N62"
Cc: netdev@oss.sgi.com, linuxppc-dev@lists.linuxppc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040914124315.716e9c68.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--aRzsUE0Mp86t8N62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 14, 2004 at 12:43:15PM -0700, David S. Miller wrote:
>=20
> Harald.... check current BK it has NAPI support added
> to the sungem.c driver already, it was written by Eric Lemoine
> with some fixes by myself and benh :-)

Gnah, I hate duplicated efforts.  Well, I learned a bit about NIC
drivers, though :(

> I guess these are one of the old mails you're resending today
> after your outage.

No, unfortunately not :(

Before I start NAPI-enabling natsemi.c (and again duplicate work):  Do
you know of anybody working on this yet?

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--aRzsUE0Mp86t8N62
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBR05eXaXGVTD0i/8RAsHXAJ4j2yIs5UG3OpHrry63kSoEZbZMCwCggnlD
tbJMCHTlYaYvYyNkeh3yogY=
=juGp
-----END PGP SIGNATURE-----

--aRzsUE0Mp86t8N62--
