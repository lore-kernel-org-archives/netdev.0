From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.10.y 0/2] ipv6: avoid soft lockups in fib6_run_gc()
Date: Thu, 08 Oct 2015 23:04:33 +0100
Message-ID: <1444341873.2956.272.camel@decadent.org.uk>
References: <20150610103926.3791.22866.stgit@buzz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nhmvkm3OdU0SpGoTDctd"
Cc: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150610103926.3791.22866.stgit@buzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nhmvkm3OdU0SpGoTDctd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-06-10 at 13:40 +0300, Konstantin Khlebnikov wrote:
> Two patches from 3.11 which are missing in 3.10.y
>=20
> I've just seen livelock in 3.10.69+ where all cpus are stuck in
> fib6_run_gc()
[...]

These also looked applicable to 3.2, so I've queued them up too.

Ben.


--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-nhmvkm3OdU0SpGoTDctd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVhbocee/yOyVhhEJAQq+Pw/+Nf/Oqeyv7+W9SWeXINyd0aDVaB/z5ClL
EKn4CZyeBBAcWVBrC1U9zVALyK9s5SkmMbyAhNM+rEyZruEc1I0DRvJKhds4T0R5
MtwLu0SQ/TDVtWUqTSAqliAa6XrJdZK2bBsOramBrxVGvn0hKmWss3tErOn3rm0F
alkHOTsCKrxBB4EnPPIjqn1CIwzuAbdyiL4uaos04YAqak/m6GGZRwpb/stJEU+a
kRwgTg/Ssjp54Vm24HesXGGv8wGeBrkNzMXlxHHWYrj3SCNFm9zfUB9K8rYBJhyt
yckPztDoi5hDMhtzgW7x5K8hqn+pU5q1BdOSj1W9U6q1nz0gYIxtqbxW29JzKOzy
9lFvIhYKoSMNB6SNFFemIKmeXeZC7KSyaADM6VZu75iSq4lQSx8JUpIVqgWNFTEp
DlPjwvBgWxgJ7nlhNHiitiR6YFLpqLy0fwNevngg1JCE74KhAIyZcFhs94ZAd130
XSZrJpbPVM6/+bHFcZe/kV0A6C3kBqcWfdPhliB/TagzK0yQ3GUdgYRXdDY8I5zn
t3FGUgFCVzPQL1QRgR2xxVn4nz7s9HmhWO6Q0e1sIynQm0XAdqRJAbmfZch4I0wR
MfhPjLC5jCmbPYaYKwkNyYiPuX3m657teDlqidpTjZ3/JI7ik86V5pxq92IJwsuD
065zx02Z9AQ=
=+RPw
-----END PGP SIGNATURE-----

--=-nhmvkm3OdU0SpGoTDctd--
