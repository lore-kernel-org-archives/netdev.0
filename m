From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH] batman-adv: Remove uses of return value of seq_printf
Date: Tue, 17 Feb 2015 13:15:47 +0100
Message-ID: <54E330F3.7030602__34137.4610121877$1424176549$gmane$org@meshcoding.com>
References: <1424136699.8287.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Hua2GoXgDPv89FdQt8o2giUhOKxdOXGjo"
Cc: "b.a.t.m.a.n" <b.a.t.m.a.n@lists.open-mesh.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:20391 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbbBQMfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2015 07:35:22 -0500
In-Reply-To: <1424136699.8287.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Hua2GoXgDPv89FdQt8o2giUhOKxdOXGjo
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi Joe,

thank you very much for this patch.

On 17/02/15 02:31, Joe Perches wrote:
> This function is soon going to return void so remove the
> return value use.
>=20
> Convert the return value to test seq_has_overflowed() instead.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>


Acked-by: Antonio Quartulli <antonio@meshcoding.com>


--=20
Antonio Quartulli


--Hua2GoXgDPv89FdQt8o2giUhOKxdOXGjo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU4zD3AAoJEJgn97Bh2u9ejZMP/2auH6FTeHEdEEPnUl0e+6Zg
gWsTCft0qbwhHyMBDaqrMYNprohYHSeceyq8+1Oa9JTOGrfHhItBht3UjUKmwXgV
dppsks9MfsZfqtXKQkc5BUj+ho21fYkHL4Tnvu0ASPekIO/zhcKJELBRcvq3ECCu
dUINtvv+qMNhZRottD4g5nhxSM7fjr0ioogOVTg6bLBfCPgUVwFeZpfB5CohpsbA
AsZY3+YNbdGuzOchXnhV9+FUkezGBhLVNaq4wXhodIANWpzRCE1l0WsCXcEn8XnY
Fck70SjSIUEGHdSPvk4zh2nl1ecjp5mIL7oe1b7dATQ1tIajBGc/NmCJwXYBvBWW
mfkfDGwhorAdFRnT9fOqaFeO4RCUaxI2ddc5Pg9k/uEsIHp8Tur5A6IdpGg99WTY
DrZKA7WReS/ZMSlSvGVhqSFQXLf+6oHvyEbKZ+nZfkmKgcUTHsHluWusB8F86TaM
JQVtE4PvKA5ehb66Lx2g+JyEt1wnLGidba8ojqI6zLNMUowaIb0K72SbB5DEM5mo
iLFCGCEZ6hk7lpv1FFaqqE8+t2U2PyE65kK0TmAM4Exddc92AsgYdUtdM0N1DAFO
BlQEyCxmij+POIimnVcI8Af5KjVyG0x1JT49jNuW5dlg2ssSpeLQatpc/HOFMWE1
rmT/VWCvkzrvC2Vpqx5F
=h/ly
-----END PGP SIGNATURE-----

--Hua2GoXgDPv89FdQt8o2giUhOKxdOXGjo--
