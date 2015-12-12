From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 0/3] ser_gigaset fixes
Date: Sat, 12 Dec 2015 19:09:44 +0100
Message-ID: <566C62E8.4010308@imap.cc>
References: <cover.1449570042.git.tilman@imap.cc>
 <1449747069.16068.27.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="JDLi8frJp4jlGbFr6WQoh4IQVTh688pvu"
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449747069.16068.27.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JDLi8frJp4jlGbFr6WQoh4IQVTh688pvu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Paul,

Am 10.12.2015 um 12:31 schrieb Paul Bolle:
> 1/3 ran into objections and, I think, Alan Cox is working on an
> alternative for it. Would you mind resending 2/3 and 3/3 as a two
> patches series? Feel free to add
>     Acked-by: Paul Bolle <pebolle@tiscali.nl>
>=20
> to both.

Alan's patch dated 09 Dec 2015 20:33:24 applies on top of 1/3 so I
reckon it should be kept.

> (The previous gigaset series, which you sent in July this year, was
> picked up from netdev directly by David Miller. Unless people actually
> prefer these patches to also be signed-off by me, I'm perfectly fine
> with that.)

I think as a maintainer you are supposed to sign off patches for the
code you maintain. My signed-off as recently retired ex-maintainer was
probably still good enough in July. I'm unsure whether it still is today.=


Regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--JDLi8frJp4jlGbFr6WQoh4IQVTh688pvu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWbGLoAAoJEFPuqx0v+F+qpfwH/Rga8O9//JCP+BU5N+F0e78H
3GE9He328Ooz5FwAoMgUhJhUnm1m8roSQtkPFed+6Dk7SqaCMbMNSPHrxNCUHUyS
PjFF94KQEkB3ZNPaYu2XDyNn9Pwb+gIhG7x4oE5H7MEnEH049PwM3yBbC+u0gEKV
ZVjRkTqenPS+VyScFNM3bcua1RP5MKOMgFYwxqHCMnRfXEJxdSG+wgCnjw1xOqcT
fdW47ejfNIQ9IwfMA/VwQdAFqTzJcIDavmnyuMUv1xWwrkRQ6ZrjyIb3Gh2712uN
jr1Fsb0V6Jf1q+FDOsnukLCeDzQPpgXeD/8arnGLuc8K87f+5Sjxz9ltexF7tJo=
=cijx
-----END PGP SIGNATURE-----

--JDLi8frJp4jlGbFr6WQoh4IQVTh688pvu--
