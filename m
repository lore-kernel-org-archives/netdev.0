From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Mon, 25 Aug 2003 13:09:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030825110903.GA17715@sunbeam.de.gnumonks.org>
References: <20021107093207.GA30666@gnu.org> <20030814131156.GA21892@gnu.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@gnu.org>
Content-Disposition: inline
In-Reply-To: <20030814131156.GA21892@gnu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 14, 2003 at 09:11:56AM -0400, Lennert Buytenhek wrote:
> Hi,
>=20
> Below is the original email I sent to netdev about nine months ago
> announcing selective connection acceptance support for TCP sockets.
> I have forward-ported the 2.4.18 patch to 2.6.0-test2, included below.
> No functional changes have been made.

That is great!  Thanks for not forgetting about this issue.

I think this feature would really be great to develop _really_
transparent proxies.

> Could someone have a look at it?

I'm not a core networking guy, but it looks fine to me.

Dave, Andi, Alexey, James: Would this be a candidate for kernel
inclusion at some point?

> Lennert

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/Se5PXaXGVTD0i/8RAnsnAKCD+2JPd5DJOUBY6xOtjWROd4rpMgCeO1dB
j9lZUVR/McLciqfBaKkoT34=
=MakQ
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
