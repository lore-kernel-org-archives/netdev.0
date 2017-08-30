From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v3 02/13] phy: add the mvebu cp110 comphy driver
Date: Wed, 30 Aug 2017 08:43:31 +0200
Message-ID: <20170830064331.GF31552@kwain>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-3-antoine.tenart@free-electrons.com>
 <50072fdd-d370-8518-a9f4-73e121114e67@ti.com>
 <20170829112340.GB31552@kwain>
 <d1d5212d-aa39-0b49-afb8-cc45d57717c0@ti.com>
 <20170829131231.GD31552@kwain>
 <04b4bb43-02f8-7b6b-f47f-f2d94d23d3f0@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="4VrXvz3cwkc87Wze"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <04b4bb43-02f8-7b6b-f47f-f2d94d23d3f0@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4VrXvz3cwkc87Wze
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kishon,

On Wed, Aug 30, 2017 at 11:01:56AM +0530, Kishon Vijay Abraham I wrote:
>=20
> I think we should just select the mode that a particular lane has been
> configured here instead of populating all the modes. But I think that doe=
sn't
> make sense since the mode is set by the consumer and the initial mode is
> INVALID. So ignore my comment on having it in dt.

OK, I'll respin the series with your comments taken into account.

Thanks for the review!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--4VrXvz3cwkc87Wze
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmmXpMACgkQXE2LyK3b
vNh8Vw//Zi7wcwM2244tBwsmiGzvsixwY+Ci1phR9kQfnv4ez6RabHWQjktS9LQo
iakW3deDC9GhgYQZhI6RFBOT4qp4bvukyKIqBlgxpCNEyqU+UDBV9/iGY2EDExwr
eWl+ElQ+S2rhM26GwYEAcQw8W1m/48jSfmkv/vGN4F3D3MZx2GZHE0+sobbWmTR5
rUBwXq1seMLjYW7W6Z5U4CLTre87jy2kms8gD2lVS7JAGfJaSV8QhZsL0eDa99hF
TLn7DEhfZ2BJ2jbFapacjd2CUzErdclUcr2eUKhtvHHNw+SSXIEj6FrV37p0x5Bi
JdTZMRDPQSLrd6UqGBi+p9gAUFA2T26rcuLCbUr58sZY8rUYS+p5jIziGAPVrvPU
KkBkvDP9XitFeGm/JE1Cmo4FFbzdi5+JADVQV7JH3m0rLaAhY50vAVqIuaBMjtOQ
MwqmBCT+88fMcBP/amdWxGmXDCga5jVeJc6WpekH1BzELntlZR8nYkWlCw4JjaPp
3US/WSbCGc9WldG+HKeWbh0f656HAgXICpecgbWPGJRxVh0br/aVsPffXVntCnwO
A7WNnypZmzGSYh0pE0PqKTdASir1qgFUFfgteB4mS+HjKo3fiXIIDoG3iO06BbYS
D1vaxIRPiX44VB+BuuhHHN54gRleAsgyxAmqeAGNl6xvHCjTWdA=
=odcg
-----END PGP SIGNATURE-----

--4VrXvz3cwkc87Wze--
