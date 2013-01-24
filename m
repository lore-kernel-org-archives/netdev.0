From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [B.A.T.M.A.N.] batman-adv: Unable to add interface in LXC
Date: Thu, 24 Jan 2013 13:17:02 +0100
Message-ID: <20130124121702.GA2507@ritirata.org>
References: <CANiGF9-dq-HrvWrgu9EMC94rP=1YdrmaFbCF2g1SZ9ocu77ysw@mail.gmail.com>
 <201212311511.24877.lindner_marek@yahoo.de>
 <CANiGF99LSHAOsKiW=mwR9v3pvEXAV8_8BcBJYzxddZ2rzCQW5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0F1p//8PRICkK4MW"
Cc: Marek Lindner <lindner_marek@yahoo.de>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: Pau Koning <paukoning@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:33608 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab3AXMRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 07:17:52 -0500
Content-Disposition: inline
In-Reply-To: <CANiGF99LSHAOsKiW=mwR9v3pvEXAV8_8BcBJYzxddZ2rzCQW5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Pau,

On Mon, Jan 21, 2013 at 10:11:15AM +0100, Pau Koning wrote:
> > Did you check your kernel log messages ? I'd expect batman-adv to print
> > something there in case of an error.
>=20
> No output at all

Sorry for the long delay. However batman-adv does not support lxc at the mo=
ment.
Therefore the error you are getting is likely to be related to this.


Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--0F1p//8PRICkK4MW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRASY+AAoJEADl0hg6qKeOFu4P/AlgX26a9cq1aOxAcP1JypYw
KQ0gB8QIbAlFM7KWm32I6oil2q+tlFb0xKc55ZH6Yn/vxvuKxXmYZNnjHxesAxuk
wlS9QS93e3bHZtvYyeDD6akMNLUSdmWLgRn/GOBnieTnBek+aK6nt9H+DABRytB0
zYcBhYQamCa41AbbGi5VLrZ0UhmElzmrGs7U+WPEgi54iyRgGIgv5PWX6S2slyQ8
95RMX/KoU49hcZ8Fn9EIuB+t4kbkNdAJG0RLZexZfUrhB+JmMdQYjTLXPxD4IJsS
RMdcJn0b5OEKwToEalZsc9ZMONcUjWzSJfKD1q/AOOCr2ebWVWx0FWTw5lhJ1xxb
3TILLgrzXE4Sm0dconpiQmPABCknb/hPYOatt0oLvfCMjEV23ZWTG7n+gZCPFmNY
SLuhbIahLPCuXMn2F/0C1505iXvbrsA1yqKT4ckLk1aFeDN95VhaBexx5ySPq22B
AxQHSDvq9FdShcOIqX6vfPSifaEpqpOONMKpBKJq4nzhm0LuAIQzQD6ZqMd0bra8
kiROpUWANbqOMYvRtRlzin+GNseYttRF50lab4CXZqNtKXY35pdT1m48pgoTmoIE
G3tXKqJGGqIOYQpRz0OyaLkh14QQppUTcxrYWpllOUbhk/q7zm+KxswHvVDkU2OX
0YLXo3FZJwAbsxUN74U8
=+e/c
-----END PGP SIGNATURE-----

--0F1p//8PRICkK4MW--
