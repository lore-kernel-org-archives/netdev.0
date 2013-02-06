From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [PATCH] batman-adv: Remove unused variable
Date: Wed, 6 Feb 2013 18:22:34 +0100
Message-ID: <20130206172234.GB6008@ritirata.org>
References: <1360168661-16871-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="GID0FwUMdk1T2AWN"
Cc: lindner_marek@yahoo.de, siwu@hrz.tu-chemnitz.de,
	davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Emil Goode <emilgoode@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:58108 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389Ab3BFRX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 12:23:29 -0500
Content-Disposition: inline
In-Reply-To: <1360168661-16871-1-git-send-email-emilgoode@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Emil,

On Wed, Feb 06, 2013 at 05:37:41 +0100, Emil Goode wrote:
> The commit ed242d01 removed a node parameter from iterators.
> This patch removes a hlist_node struct that is no longer used.
>=20
> Sparse gives a warning:
>=20
> net/batman-adv/originator.c:411:21: warning:
> 	unused variable =E2=80=98node_tmp=E2=80=99 [-Wunused-variable]
>=20
> Signed-off-by: Emil Goode <emilgoode@gmail.com>

On which tree did you base your patch?
I cannot find the commit you are referring to (ed242d01) and the patch does=
 not
apply (neither on net nor net-next).

Other than that the variable is used a couple of lines below (in the code we
have)...

Regards,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--GID0FwUMdk1T2AWN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJREpFaAAoJEADl0hg6qKeOYX4P/i4w0uWSngHmhIUdsAaWQEX7
ZJWVkVVACbcmcgYUO0rtq7HLd9gthwAllNdNj8YAM1G++fGmRWMNPD5jb2WBNgGQ
rnMl4bMRK8i8laebOC3MK44lUSqxgfMWA4p2FnJgnHwxYdUSTdJqWag2RQRyof22
/K2GZUKo3O1DmGVXFrLNCUGwWHu4oz+nKxtk3PhxxG9Q/2bmtyxd9TVr5dvMlRgr
d6j0YiOuP4Z8jQY1i1JmhmqHZSsTvslhudEqMy2KGCXzAhGKJHFeedQVFwpnn6p4
2Q1HMd9NB2uCqklKJ3URiwo8CJ+jgpS0wdQNIFscwyfHIYJaVdC/BNbIgpl/vSqt
aL9diRpfYxp8d1lz7FZJ5oKHsN8AsNkkyxvA9PJVwOcmR1LYDoc7ZfOSaRPn+pJT
kHvcJu6Sf564QMmUzeeLCr1C8hwJolcPKjJtO+tWePhL9FmRr3rai1LETIvXfk05
JwSJfGFMcoJI0Rhxk7VwndCrxBHLhuJfVsQz/mDFnx0+9Cx7fLHidciBB9DiwdTK
IAG0WmYvuHqdIsZKPMphZhjRTynYPzCwzvc43D8bq65EhqYMGQJmyQ8PUZQcPuZp
e5Kzg7sQFd/eluq66cfKP779B/mB0N84il2HhGCDqK3iOxB66aNEkfazVBofx27C
lgnYZRB01Jf3+usHFOyk
=u0Md
-----END PGP SIGNATURE-----

--GID0FwUMdk1T2AWN--
