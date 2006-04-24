From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Mon, 24 Apr 2006 09:41:48 +0200
Message-ID: <20060424074148.GB23340@zion.homelinux.com>
References: <20060421010809.6c3cfc34.akpm@osdl.org> <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com> <200604220202.59434.ak@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/e2eDi0V/xtL+Mc8"
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Nuri Jawad <lkml@jawad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:8103 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1750818AbWDXHlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 03:41:53 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200604220202.59434.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/e2eDi0V/xtL+Mc8
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Apr 22, 2006 at 02:02:59AM +0200, Andi Kleen told us:
> On Friday 21 April 2006 19:15, Jesse Brandeburg wrote:
> > On 4/21/06, Andrew Morton <akpm@osdl.org> wrote:
> > >
> > > We do seem to have had a few reports of ppp regressions around this
> > > timeframe.
> >=20
> > me too.  I couldn't use 2.6.16 at home on my pppoe connected router
> > because it was so slow.  I didn't have time to debug.  I can probably
> > try patches and provide more data too.  Tell me what is needed.
>=20
> I seem to have some trouble on my PPPoE too. But it's not really unusable,
> just dropouts now and then.

no problems here with pppoe, kernel is 2.6.17-rc1-mm1, ppp 2.4.4-b1.


Sven

> -Andi
> -

--=20
Linux zion.homelinux.com 2.6.17-rc1-mm1_31 #31 Sat Apr 8 16:18:23 CEST 2006=
 i686 athlon i386 GNU/Linux
 09:40:22 up 1 day, 13:14,  4 users,  load average: 0.34, 0.16, 0.11

--/e2eDi0V/xtL+Mc8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFETIE8o4FAdB2PneQRAuynAJwIZNhzz1ECU0asfvU1PHTt4MNelACfW9lS
WcoD3OR1cscG8RC4KNCR2aQ=
=LbeY
-----END PGP SIGNATURE-----

--/e2eDi0V/xtL+Mc8--
