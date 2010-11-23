From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: addrconf: refcnt with  IPV6_PRIVACY enabled
Date: Tue, 23 Nov 2010 17:17:07 +0200
Message-ID: <20101123151707.GA4076@swordfish.minsk.epam.com>
References: <20101123134003.GB4142@swordfish.minsk.epam.com>
 <1290522803.3046.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290522803.3046.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (11/23/10 15:33), Eric Dumazet wrote:
> Are you sure the problem you try to solve is not already solved in
> commit 88b2a9a3d98a19496d64aadda7158c0ad51cbe7d in net-2.6 tree ?
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommitd=
iff;h=3D88b2a9a3d98a19496d64aadda7158c0ad51cbe7d
>=20

Seems to work for me.=20
Sorry for noise, thank you.

Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>


	Sergey

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iJwEAQECAAYFAkzr2vMACgkQfKHnntdSXjRqSgP/aBgyAjrdSbujD1o4fH0c3F7c
yIruwfy+WWsHUaQV/THiWI7jupYW2DTrwZQZa9PpH9IWh5Bp9DmQ5XcKXQsYv+1R
OZ0mKmFGbl63kH+BXhdMZIFdU4Oe5JsVuMNismb3g6jOndVv/umXrMpjHaeC+bUS
st5Y7f5vkQnvP0ecqTo=
=BMCe
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
