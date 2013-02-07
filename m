From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [PATCH v2] batman-adv: Remove unused variable
Date: Thu, 7 Feb 2013 08:13:05 +0100
Message-ID: <20130207071305.GG6008@ritirata.org>
References: <1360193557-27554-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="QWpDgw58+k1mSFBj"
Cc: akpm@linux-foundation.org, lindner_marek@yahoo.de,
	siwu@hrz.tu-chemnitz.de, davem@davemloft.net,
	sasha.levin@oracle.com, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Emil Goode <emilgoode@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1360193557-27554-1-git-send-email-emilgoode@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--QWpDgw58+k1mSFBj
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 07, 2013 at 12:32:37AM +0100, Emil Goode wrote:
> The below commit removed one node parameter from iterators.
> ed242d01bbe22ea0877472db49b2752d866c921c
> (hlist: drop the node parameter from iterators)
>=20
> This patch removes a hlist_node struct that is no longer used.
>=20
> Sparse gives a warning:
>=20
> net/batman-adv/originator.c:411:21: warning:
> 	unused variable =E2=80=98node_tmp=E2=80=99 [-Wunused-variable]
>=20
> Signed-off-by: Emil Goode <emilgoode@gmail.com>

Acked-by: Antonio Quartulli <ordex@autistici.org>

Thanks Emil

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--QWpDgw58+k1mSFBj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRE1QBAAoJEADl0hg6qKeOIbQP/0619SbVBdH3FJ7s6Z7LFgI/
wo3N/zUqxX4oIzR4lSfKRmFks7JoEnXneAK/tEr5YRzGFdeC9y9/ua7VQ3PCL7t8
ivsB+qJ/be2ZyOn9QLY72e1sR5zn48HZLNdqGNGgoDY+C8H1qCZBNt3DY2sbpRpS
Ojxp1jhl/PsFvqY2WXq6Vwvv0l85+ZY11fHACKAFrsDnKfJSuFxniQ09ir/Y/kHA
L9CDGVHOTnkVFQitAs5y0fnIH3wwU8CSMF1DHGuNK0h/WBwuAQoXceO10bqKijcH
guFY2kfJp0wyFsJmVIw/5CbdMBiYKgSlu7YynI9XbF/vahZUrcblW7qd9zzVABge
t3SrtU3/oPWsSgMcpsZqHQbiPCg2z1zt7On46ExEpIqh3K7EcmvCyhLXNbQXR5H/
DBV5/aY8yHEyq+njhenht4wteRHaFOF7n60MEuf2tr8d5A7dQUGVi+/gS4p1Ul91
Rda4dV+2bcuMVNLPYuuxeY8HLm+ahvbPSdMsvxK+yyZ1z0fpiK+fPljB0gUBoDHp
MWc2AFQ9WXQmjkhzW1m63C1ZwQ/z4Af8FOfM0k8JAhLc0fKAz7QgMp0RekisZ9NG
AK2ZAxflxoI+wbZOI7uRvs/rzQqARhxf4AfzY4fNYeQDHsOWwgljazCTXEMblXX4
UgowgwUjnmI8dHLfQv7D
=SB6i
-----END PGP SIGNATURE-----

--QWpDgw58+k1mSFBj--
