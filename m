From: Doug Ledford <dledford@redhat.com>
Subject: Re: [for-next V2 00/10][pull request] Mellanox 100G mlx5 4K UAR
 support
Date: Mon, 09 Jan 2017 23:29:22 -0500
Message-ID: <1484022562.2149.5.camel@redhat.com>
References: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-Vb/tK7rHbdqO4vFW/FVg"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Eli Cohen <eli@mellanox.com>, Matan Barak <matanb@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764760AbdAJE3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 23:29:24 -0500
In-Reply-To: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Vb/tK7rHbdqO4vFW/FVg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2017-01-08 at 17:54 +0200, Saeed Mahameed wrote:
> Hi Dave and Doug,
>=20
> Following the mlx5-odp submission, you can find here the 2nd mlx5
> submission for 4.11 as a pull-request including mlx5 4K UAR support
> from
> Eli Cohen (details below).=C2=A0=C2=A0For you Doug, this pull request wil=
l
> provide=C2=A0
> you with both mlx5 odp and mlx5 4k UAR since it is based on Dave's
> net-next mlx5-odp merge commit.
>=20
> v1->v2:
> =C2=A0 - Removed 64BIT arch dependency.
>=20
> Thank you,
> Saeed.
>=C2=A0

I know you have a couple issues to fix on respin (minor things as
pointed out). =C2=A0Otherwise, I've reviewed of the IB portion of the code
and have no objections.

--=20
Doug Ledford <dledford@redhat.com>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-Vb/tK7rHbdqO4vFW/FVg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYdGMiAAoJELgmozMOVy/d9doP+wWhPO3DoU69rbUqVqRwj/qq
VSna6IxHdla5nrKGAnvF20HgWXxQ4D8JRk7RUtDKzHcmyTQf24S/kiBbDbF1AVNi
q1WD7eeiJ1EK1ytacVgaqgHJ8H2Sse4Qo3NYWiRizI/64CgWJsnAWnoa06qAFOMd
/w9VHObD3CwFBsiXQs6JgHZUoAfSVKPdUlJdvWqRwhaZpLHUC6SL0Wqji2JJqx1Z
+NEmp74FLdDmms8e0npbzNOJXfRs8n4ysXVQaeJK4N5W+nq/ZYXJyInhkunpLrbz
Z5FJv7PmmFs6uERJbgrKniGONGXv1jBfsM3LGaDYY2h93QXxc7Mp9m9LANLK1WwT
lAgCxhN+tJRwVZgxR0XDju60l/3EX5dxrxyGZl3tiKtalGbwG+FEkdC5PYC8POEk
qjFLwvyLHHmP1YNn6ayqeDwZ4+XEtw7/DzM3mfdOy0IXvdRZwSfljkcUKPN8egFK
0X1Qn5le923dYPMTD+YhlC7EFZO6Ump95Ua0Rj4o01Ozd0MMFlflyLjXzPnWNEZi
dVJqkkLYHgdO0r5HxdVWkT1t2F+fWJO9bTjJ5adH+p95KqqwD6+ZPwjmnWv21i1y
7lUjEfUFbuFBBCgH8wFlkG7EevyLEIqPNf4wdSOYCrWBe6UTGcEXfPJh079e2UQ3
P9BIaMrob1sfBAReAag/
=HgS+
-----END PGP SIGNATURE-----

--=-Vb/tK7rHbdqO4vFW/FVg--
