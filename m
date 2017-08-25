From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 00/14] net: mvpp2: comphy configuration
Date: Fri, 25 Aug 2017 17:56:37 +0200
Message-ID: <20170825155637.GB31644@kwain>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825155111.GD30922@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="v9Ux+11Zm5mwPlX6"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825155111.GD30922@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, Aug 25, 2017 at 05:51:11PM +0200, Andrew Lunn wrote:
> >   - Checked if the carrier_on/off functions were needed. They are.
>=20
> Could you explain the situations they are needed in?
>=20
> Quite a few drivers do this, so i'm not saying it is wrong.  But it
> would be nice to understand if we are missing something in phylib.

I know it's not working without these calls, but I can't tell why (yet).
I can try to dig into this.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--v9Ux+11Zm5mwPlX6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmgSLUACgkQXE2LyK3b
vNj+8A//V2N013IfoV2+moVFhDD2mgLN4dHOrXaQD+WuUtpXWL8RvBnEPiMdrp2N
2+zanu8CvAVqZxaoH7N8QdFACTRdCJDwE1OSVa3bZHdL7J5KJFDNqb59VOGueuQH
p7u9qU+Aqe9s7sfE3cAvlWgZSltgLqeQOTuAPPizDX3eXid9i1rd4SmjgvAbwI97
dHnLolRV/r33w67IEdup6+ye5Sf5TkhXF59rmU3pLHAuh0ADeoIvDDs3iLqoPjCp
s1NCf+uBnKbbtjfglv++lqx8ztXHlN4gmlpZmCQcKes98fkz0B7A/rh78qg3Vv3B
M8TlTGdYENHp30miOxZXDQoNU3PmDb9RuE+K0+QnjZ94FesUUeKYSJ7lyQI2qFND
+L2uh+NzTuDkadqnl7Jv+IwQjjUKvT/oUE0Ock4I85ZzCbMx35QLyPKMUV58diYs
oCBm35GKevaQmR9sfJEZdFXvc17emPXeqZQr68pp7llCRoJv0mBC27/02c+9dyN4
W+XrKGp0iweHiNgELoHN+BML1WyN4hOpFiLubxeM9euBljdxsdrkUpbF2fjaXBBh
Is4Z5nrNyt4k7gIiPNGQy2oXfnKcFLAOxajDl+PvfmWGRHfh2QD73wNBwsxdIyQr
nTp/oJGjz14tjJDfPbZJweLRgIOp0WZMxitO2Tm8P/KFlra2Dds=
=T9S9
-----END PGP SIGNATURE-----

--v9Ux+11Zm5mwPlX6--
