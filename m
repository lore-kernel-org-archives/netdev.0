From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [stable] tcp: drop SYN+FIN messages
Date: Fri, 13 Jul 2012 02:59:24 +0100
Message-ID: <1342144764.25597.377.camel@deadeye.wl.decadent.org.uk>
References: <1342143978.25597.376.camel@deadeye.wl.decadent.org.uk>
	 <20120712.184958.1901534669754870330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KT6vrQwfU9i0xekYCmxB"
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44392 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932250Ab2GMB7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 21:59:32 -0400
In-Reply-To: <20120712.184958.1901534669754870330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KT6vrQwfU9i0xekYCmxB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-07-12 at 18:49 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Fri, 13 Jul 2012 02:46:18 +0100
>=20
> > It looks like this is needed in 3.0.y and 3.2.y:
> >=20
> > commit fdf5af0daf8019cec2396cdef8fb042d80fe71fa
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Fri Dec 2 23:41:42 2011 +0000
> >=20
> >     tcp: drop SYN+FIN messages
>=20
> Sure:
>=20
> Acked-by: David S. Miller <davem@davemloft.net>

OK, queued up for 3.2.y.

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-KT6vrQwfU9i0xekYCmxB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT/+A/Oe/yOyVhhEJAQrFDw//YxQakdbVUeOOoW70i0RYVgvixc/6RE17
xylj5nc8mlTYxF+Jca2WROm/2uFw7bOxTB4KwUUyrbusLlLM/xwVUKh728xKYkdu
KZtP84Lwi43W59y9Olo1F4KyVy50qgdkipry4QG0UFZ7GT1McyjMvR0aZ5DifFnc
V1ehCifqvm5YAgngxFQVGDmeky063vhJZo/yUpWb+xQqWXI71Pw1BYwyAGyyHxy2
swXc/U3WU3U8+S/QWbm5SnDlNUKyHf6bG6J9+f+faLs/YkbOxO2zt2As61peUcpz
Z8W70whBzhrsnD9JzCwah3q6HZTQxHvhl/f2M0NqD2e9dCWZMjj+aWBB8GB/Sg0U
FMYIIeC5ZifkTLm12cd5j23BZ+UvKzNqYq0YWtmf9vy4wy9zJ28fd2YBfOwV4X0r
0Q84ORa8BQqb2OhVUxD8c6BeFgy4lHI0uhLZ0kSE9XyR1D21ebG2J3KwLWlpLFz+
XVt7PbJNIwnKQAhN1sXrh9FUrJMfSJY8X/J8WvcWBH/V7KiQUmRxMoMyCGCHA328
7yJHRW39s0LZ8vCF0Ku1p6rgJMSGrTGvvid19IvMbJ6Qmqp7gZqRh1dUSz/YofpI
UUXCWRKUnw+U7+vreq7TKNUmO+XdBxAyqwsYHvcDWvlyi0UldjPpsKypLTPFv5Vr
ZeQ+Dm7upE4=
=AEIZ
-----END PGP SIGNATURE-----

--=-KT6vrQwfU9i0xekYCmxB--
