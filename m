From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 01/13] phy: add sgmii and 10gkr modes to the
 phy_mode enum
Date: Thu, 24 Aug 2017 15:31:46 +0200
Message-ID: <20170824133146.GG23960@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-2-antoine.tenart@free-electrons.com>
 <20170824131938.GB8022@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="/Zw+/jwnNHcBRYYu"
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
In-Reply-To: <20170824131938.GB8022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/Zw+/jwnNHcBRYYu
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Aug 24, 2017 at 03:19:38PM +0200, Andrew Lunn wrote:
> On Thu, Aug 24, 2017 at 10:38:11AM +0200, Antoine Tenart wrote:
> > This patch adds more PHY modes to the phy_mode enum, to allow
> > configuring PHYs to the SGMII and/or the 10GKR mode by using the
> > set_mode callback.
>=20
> You had me confused for a while here. If there is need for a respin,
> could you change the commit log and prefix PHY with either generic or
> Ethernet, just to make it clear which PHY subsystem we are talking
> about.

I understand the confusion :) I'll update the commit log if there is a
respin.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--/Zw+/jwnNHcBRYYu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme1UIACgkQXE2LyK3b
vNhlvg//WY5Qw8D2FeC4zHFI8+33WF47xqdOHLWkHXC14EnvrXNq1TrUaEoJ7YuI
OFjDBGh/MMfLAvi4i5qfIhsf/W7GUmu9NkfbRBda1Omg0M1EW8uAUz6xpRjw81c7
pfVGPlhRA+XZ0+01z2h3CxZocrlbpVvr3XMpEsrAxc4bYB5/qoFg6kpIqqYlDNnJ
rGRdSclxmcNVPPRL2Erh7Wo0Hl7iy84Z1bVRqo+xFZaJxqLqJ0qJ0KJA6ZxjL3OR
DCPvgegcWdyrJLagic66Hy2jgNCqQKWNJiDLjnFyjgASbxStxv8t2c8RKXun69V2
Qy5fVl2KpJE8FMz/D4+pSmCo9rPb2fslv0l+t7dgqChC2jDOxm17LS1+tzSdqHgH
MV6J8/TCkDhoS/JS0a8LFbwufafo7vKnarEaWXLT8m18rs9LDFfNLTj5p1G0FK4j
PQgsnWXIa1k515yXg5GRaIHTyQWfEPNHy65e8a4uj6g3sc/RWOZq8t3x+lgmzUoG
zRaUDvJWlTTlFvMT7kS+2q4QQp7OADGPSLyUrlOkQ6zNaJS07yz4og9ChmBCnKw6
hLLCyKz3DD1wkklNsGjF9Q3pwxNMMLhFs/o0Vj3HNlksuWX3WYu7bn/i5VO4IR87
13bVFDOPpTFrnZVargaOcHiH05PMTUY4Sq/X4DtMOKbKDfNCkzs=
=08v+
-----END PGP SIGNATURE-----

--/Zw+/jwnNHcBRYYu--
