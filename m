From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Sat, 01 Nov 2014 01:29:13 +0000
Message-ID: <1414805353.16849.98.camel@decadent.org.uk>
References: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fzRKpeqwBGMdrJTpgfD4"
Cc: "David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>, netdev@vger.kernel.org
To: Vinson Lee <vlee@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55277 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750808AbaKAB3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 21:29:37 -0400
In-Reply-To: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fzRKpeqwBGMdrJTpgfD4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-10-18 at 14:14 -0700, Vinson Lee wrote:
> Hi.
>=20
> Please consider backporting upstream commit
> 2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
> race" to stable kernels <=3D 3.11.
>=20
> commit 2d4b646613d6b12175b017aca18113945af1faf3
> Author: Eugenia Emantayev <eugenia@mellanox.com>
> Date:   Thu Jul 25 19:21:23 2013 +0300
>=20
>     net/mlx4_en: Fix BlueFlame race
[...]

David doesn't support anything older than 3.12 now, so you should send
requests for older stable branches directly to the stable list.

I tried to apply this one to 3.2-stable, but it failed.  If it's needed
there you'll have to provide a backport.

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-fzRKpeqwBGMdrJTpgfD4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFQ3dee/yOyVhhEJAQpI7xAAqr5bAmRIP1w7BbC7LGAhHvQjTdkUe2bQ
njMIcVkl0/9704MjI2OmQ34l73ddhyfow6DpdrIizK+zmEusrYCGqxaqxsotOPKF
QwZJLXgtRJKrZNBBX6JLalrU2qipSJ+FD6Cx9xm4yh3UvMvJihsEuK8r2y0QAbm4
4BAHhFTIr947niQOT+uTmIxNoD9XYAML0K5rOv/lNbLdDeLcEqIw1ytFRUU9I0Da
LrFIhCiURFPjZKcp/Y8kZPg07ecZwF5AULkAeTFK+JyB70PPhHAayUNDgO5efHFN
2zpT8+QEAud0Sas8HoU8OlLyclwA3+gSfUF7kmbIbpqmGGVtNSpvkO4PpUfcL79W
+wwAHlsVa67GaRDic6o8n6vwF8lsLYN+3OUn1wR9/x8+TVtthNQyuZmKWz/H0j5P
y077sU1/FYbMeWqrAkI1FapcdB8f/o4S1NvUc6xtDbO6c4fqA/sVG+NQ4fomXYLc
rIxrWfKZumgbDokCagcnYuY49VvaqJtn6F263FBMhbaDFVQsVQe5OlvJcKUW7s3s
BoPFoyhkXbGLYSx+KYQkgd4fjYRzeiJHcZUms9KW0nimHQFAguSSaBDhOO3AQS+W
bjCcX4EbzGQ01AIFr5mH2DeSDS5/b/BMK7K/+nUNPpSjie/QhrvPgiI4Lq8VDwRp
AmkRVweDXV8=
=deFx
-----END PGP SIGNATURE-----

--=-fzRKpeqwBGMdrJTpgfD4--
