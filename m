From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH linux-firmware 1/1] qed: Add firmware 8.30.16.0
Date: Mon, 09 Oct 2017 18:23:50 +0100
Message-ID: <1507569830.2677.134.camel@decadent.org.uk>
References: <20170913104645.21599-1-rahul.verma@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-NTyiLQNKCUK+9X6WIqHJ"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-firmware-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Rahul Verma <rahul.verma-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, kyle-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170913104645.21599-1-rahul.verma-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-NTyiLQNKCUK+9X6WIqHJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-09-13 at 03:46 -0700, Rahul Verma wrote:
> The new qed firmware contains fixes to firmware and added
> support for new features,
> -Add UFP support.
> -DCQCN support for unlimited number of QP
> -Add IP type to GFT filter profile.
> -Added new TCP function counters.
> -Support flow ID in aRFS flow.
>=20
> Signed-off-by: Rahul Verma <rahul.verma-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  qed/qed_init_values_zipped-8.30.16.0.bin | Bin 0 -> 837008 bytes
>  1 file changed, 0 insertions(+), 0 deletions(-)
>  create mode 100755 qed/qed_init_values_zipped-8.30.16.0.bin
[...]

The new file needs an entry in WHENCE.

Ben.

--=20
Ben Hutchings
Humour is the best antidote to reality.


--=-NTyiLQNKCUK+9X6WIqHJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlnbsKYACgkQ57/I7JWG
EQnE/RAApv2F37Goi1XM+f1nDLi2ViAtyJaPGM7ZOz8PQqXkqEClzF43odDwRXFY
TKunkNWN8me5kCIdhViQ4/CILXU9ljVlhPkVdsfArmIi4BjQ5yzYlHTB9DWWqSI+
5ULMGzomBReXCqfOJD7njR0/cDuZW6sT1G+cKJ+CmHp7kPzr27cZCpcoMk6z76Pn
3vqVgeYzDYhr+HKqdwpmbtWtqTLHSTZaZCnQl9TUpVrZJ76XPVBr1+myYIyVbrSs
FlsVH/zDIXHhK2VqXcDuB9eMeKJMPCk16KjtTveAeINKwRH3Cf+rlt7QEWBi8IPK
Sz1yoFexrjS/Ola8n2lUHR5QvoypEb5kQJwZpIQp+hDZS7imehYe2J+BxlNh4IIR
aJkw/92ul/OY3o3vj6uaVyVcIHlyXljAXKQofMMJZhO9Hn1WWl2NqCiacQWL61s2
PduK1JUy9hWaYh6XzVePjay0EvZMkSorEk9dl/j1pP/l5qJ2nvdHC2ck/3WtbSu2
KqyvhDBtAV5PmQX7Hi09z5sUtTSY+cSofVUcx9cExyH5/uL1EABWKFGUYgCV1hEq
nzKc2tgbwUJDKzqqvyZcnJAC8lgWdrl/vH2Nr4uB/e0q3LVOm+EGAaJP+RxdilEa
/tbvd+2eqh901lWwVRDEs57kCCd504QxvhlzN0ph1lj86pNUR3M=
=AIfo
-----END PGP SIGNATURE-----

--=-NTyiLQNKCUK+9X6WIqHJ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
