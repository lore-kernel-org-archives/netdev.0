From: Harald Welte <laforge@gnumonks.org>
Subject: Re: Replace the Nagle Algorithm
Date: Sun, 2 Nov 2003 09:35:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031102083555.GG1536@sunbeam.de.gnumonks.org>
References: <sf93dbf5.079@prv-mail20.provo.novell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4ndw/alBWmZEhfcZ"
Cc: netdev@oss.sgi.com, jrd@cc.usu.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Joseph Conlin <JCONLIN@novell.com>
Content-Disposition: inline
In-Reply-To: <sf93dbf5.079@prv-mail20.provo.novell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4ndw/alBWmZEhfcZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 20, 2003 at 12:58:19PM -0600, Joseph Conlin wrote:
> I see in the archives and the code that I have looked at (2.4.22,
> 2.6.0-test8) that the Minshall algorithm is being used to reduce the
> effects of Nagle/delayed ACK interaction.  I haven't seen any mention of
> the following solution, proposed as an IETF draft RFC by Joe Doupnik
> (jrd@cc.usu.edu).
>=20
> http://netlab1.usu.edu/pub/misc/draft-doupnik-tcpimpl-nagle-mode-00.txt

Interesting, but do you know why this has not been aprooved as RFC and
never became more than a draft of the TCP implementation working group?

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--4ndw/alBWmZEhfcZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/pMHrXaXGVTD0i/8RAvh+AKCSFS3PebGTt/FCcSXclZP8gs0nxACfcbgh
XBIxvcDguLxJdDpMKxyCAvc=
=H46q
-----END PGP SIGNATURE-----

--4ndw/alBWmZEhfcZ--
