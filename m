From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net v2 1/4] net: mvpp2: fix the mac address used when
 using PPv2.2
Date: Fri, 25 Aug 2017 17:54:31 +0200
Message-ID: <20170825155431.GA31644@kwain>
References: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
 <20170825141420.14027-2-antoine.tenart@free-electrons.com>
 <20170825141939.GB30922@lunn.ch>
 <20170825142928.GB31512@kwain>
 <20170825154247.GC30922@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="a8Wt8u1KmwUX3Y2C"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825154247.GC30922@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 25, 2017 at 05:42:47PM +0200, Andrew Lunn wrote:
> > So probably the best way to handle this would have been to send 1/4 to
> > net and 2-4/4 to net-next
>=20
> Correct.=20
>=20
> > (but then there's a dependency between the two series).
>=20
> Dave merges net into net-next every so often. So you just need to wait
> a bit before submitting the net-next parts.

I see. So Dave can take patch 1/4 and I'll respin the others once it's
merged into net-next.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--a8Wt8u1KmwUX3Y2C
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmgSDcACgkQXE2LyK3b
vNhmRw//VZph0itL8bP+n2/SKjgHJbX7vCj8652roNoaJks11lH9njGkzSHhUcNa
shVOMdDXNObjQojnP2mM7FMNL3QljZSqV8EoGPdGCft2WePdbIovx1iTi4/AzWaV
MYCILo0H8wxZu4eGB/7VQggx/orKcyYjucnADX5uglllgmpUiXF6e1YGsWxAXZZA
7PwP0snD7hFtZTczDNyT6LcpV4nBZ7ykTpqJrMP7N9BuGyqinW6/NWocpknOf8WA
Em3tR46pHZNkqgQUk83CqSFuAv3GypMzLkpeTBnGNVv0quCV/hoprXTC5mRz9y6T
Sp3FWOrfyZW0r10cVhKAPkS6Mr2yTmld6CyuPLOhBA1rsLMBgwW856CIiQ7+FIiT
Bzn8v7HLG48yxPKMle+YRlkKTau5MYoIRl3V2Jkq+wfDG3Nx5+PKSna98BH9zzES
1n9Miriui/qu5n4GQgunV0X0oVD2uBxjwf5RHXDKG/1Kmyo7EZcVSBNstNX4xpkB
LD0BT3pzklRR9qRwBgJBhrZ5Q0sMq6sJ4M1gG9OvRuRITaTf50YiSxnHjfbFYmiN
+SZC+n5SENAiLdv3YMcXg91f2Li8f/qNx8YOHXunlYzY5MvIw/AIuVr9dUKtUhBK
6jPLVAWc/ztf9tv6gIfAiRItn7z1rgr2Pgr6T+mt/FT12QBRxhE=
=e4ow
-----END PGP SIGNATURE-----

--a8Wt8u1KmwUX3Y2C--
