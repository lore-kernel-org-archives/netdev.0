From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Wed, 26 Apr 2006 08:04:42 +0200
Message-ID: <20060426060442.GA8875@zion.homelinux.com>
References: <20060421010809.6c3cfc34.akpm@osdl.org> <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com> <200604220202.59434.ak@suse.de> <20060424074148.GB23340@zion.homelinux.com> <Pine.LNX.4.64.0604260126020.12542@pc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Cc: Andi Kleen <ak@suse.de>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:49092 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1750768AbWDZGFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 02:05:45 -0400
To: Nuri Jawad <lkml@jawad.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0604260126020.12542@pc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi,

On Wed, Apr 26, 2006 at 02:36:18AM +0200, Nuri Jawad told us:
> >no problems here with pppoe, kernel is 2.6.17-rc1-mm1, ppp 2.4.4-b1.
>=20
> Did you create a high load on the system in the manner I described?
> The bug once only appeared after about 6 hours here when line + CPU had=
=20
> been mostly idle. But that was the longest time between failures. Can you=
=20
> test with one of the 2.6.16 kernels I tried (latest was .9)? Can't say=20
> for sure if CPU load is a factor, load on the connection seems to be.

well, machine is mostly idle beside downloads now and then or
software compilations (kernel mostly) or periodic mail fetching
including virus and spam scanning. This is my box at home (on
which I'm currently writing this email). I'm currently compiling
2.6.16.9 and will test with this release later on. I will get
some periodic ping running to check for connection failures and
put some load on the machine. Will come back with the results
later, but don't hold your breath waiting for me, kernel compile
takes more than two hours on my box :-)


Regards,

Sven

>
> Regards,
> Nuri
>

--=20
Linux zion.homelinux.com 2.6.17-rc1-mm1_31 #31 Sat Apr 8 16:18:23 CEST 2006=
 i686 athlon i386 GNU/Linux
 07:56:45 up 3 days, 11:30,  2 users,  load average: 2.79, 1.32, 0.68

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFETw16o4FAdB2PneQRAqFFAJwMzpbe42OK0YCWu7FiLRrcx4kr2wCfbFMx
TTwPU+SJPzxE05KATOxTKlc=
=xFAV
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
