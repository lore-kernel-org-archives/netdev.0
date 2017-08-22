From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 00/10] net: mvpp2: MAC/GoP configuration
Date: Tue, 22 Aug 2017 20:38:05 +0200
Message-ID: <20170822183805.GD14942@kwain>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
 <20170822180757.GD18076@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="DiL7RhKs8rK9YGuF"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:41412 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752527AbdHVSiH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:38:07 -0400
Content-Disposition: inline
In-Reply-To: <20170822180757.GD18076@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DiL7RhKs8rK9YGuF
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Tue, Aug 22, 2017 at 08:07:57PM +0200, Andrew Lunn wrote:
> On Tue, Aug 22, 2017 at 07:08:20PM +0200, Antoine Tenart wrote:
> >=20
> > This is based on net-next (e2a7c34fb285).
> >=20
> > I removed the GoP interrupt and PHY optional parts in this v2 to ease
> > the review process as the MAC/GoP initialization seemed to start less
> > discussions :)
>=20
> By that, do you mean setting the SMI PHY address?

Yes, the one set in the GoP. You asked more precisions but I need get
more info to answer, so I removed it in the meantime.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--DiL7RhKs8rK9YGuF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmceg0ACgkQXE2LyK3b
vNgTTA//eWeiMp3HXIFs/XbPYWYpz1ZCpeJDp4uSfqilsVX5YCVOwYo9UviNHDFK
FvAlVRr9xafP5falT+Tc5wlYOrLSfasweKHGec19h57Pu2hTB+dt3DV3XfIrKwkJ
rIHfV6PiSs8AWXgJPwSeFCuWCPoHB9LwXhuTXpSyXiI3lwkXpqEmI4zUHrutvYBG
dhzgLkZ4LPna/VdwotBPxFxMCpnsTgLZ7l5wLJqP+D9ZxgCEa1EDyP/MLr1rquZO
9nIzuJnZLL5sqyDGOvGhpPdO+8SAlCGfyd5WB/slCQbiOU4uKoNs1r8E7SiTEuKw
Fbs1x7RymX2TQAXiZlNDkp7ar+6eJ+FlhI7TYOMitd8BNVMXBarDasBclzjhBzm8
DtARxvW52fR24Sorz+EP0szd8V3G2LCdrATgGZSXTdZfu9el0VvYVhhxlkI4bNjy
IpWLp8WOEg6is+V/ifBTeijIX6D08e5nod4bYgCv8y0FPZCJAstfPIOn8bJNB1Xv
cqcaHv08v5b7kGRs9sKHHsizFfWk9cRlVoSUDBlTxT1Hfrn89DO1aCOTYn2/0Zph
PR9/oLN/RRknbH6do447/Bu5WqLkXcHe/T3pN3ThhcX6jqkLSxDK+raDhtQwrrFQ
yeHivmo1pEwE4edX5MrhPChEz9cBjwr306LBocKf3B5uCDCGRxw=
=Te8o
-----END PGP SIGNATURE-----

--DiL7RhKs8rK9YGuF--
