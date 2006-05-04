From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: Re: RFC: au1000_etc.c phylib rewrite
Date: Wed, 3 May 2006 23:49:45 -0700
Message-ID: <20060504064945.GE12203@curie-int.vc.shawcable.net>
References: <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3> <1146510542.16643.10.camel@localhost.localdomain> <1146510542.16643.10.camel@localhost.localdomain> <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3> <5.1.0.14.2.20060502095256.01fd4210@205.166.54.3> <1146674056.31241.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="maH1Gajj2nflutpK"
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pops.net-conex.com ([204.244.176.3]:36536 "EHLO
	mail.net-conex.com") by vger.kernel.org with ESMTP id S1750710AbWEDGtk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 02:49:40 -0400
Received: from curie.orbis-terrarum.net (S01060050da688d47.vc.shawcable.net [24.80.100.253])
	by mail.net-conex.com (8.13.4/8.12.11) with ESMTP id k446nd9o017199
	for <netdev@vger.kernel.org>; Wed, 3 May 2006 23:49:39 -0700
To: Herbert Valerio Riedel <hvr@gnu.org>
Content-Disposition: inline
In-Reply-To: <1146674056.31241.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--maH1Gajj2nflutpK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 03, 2006 at 06:34:16PM +0200, Herbert Valerio Riedel wrote:
> while at it, does anyone happen to know what the phy-addr/MAC assignment
> on the XXS1500 is?
Nope.

> but one thing that seems strange to me; CONFIG_BCM5222_DUAL_PHY doesn't
> seem to be defined anywhere; shouldn't that be at least defined in some
> Kconfig file, especially if the XXS1550 board is supposed to make use of
> it?=20
Hmm, I do recall submitting a patch previously that added=20
'select BCM5222_DUAL_PHY' for the XXS1500 unit.

--=20
Robin Hugh Johnson
E-Mail     : robbat2@gentoo.org
GnuPG FP   : 11AC BA4F 4778 E3F6 E4ED  F38E B27B 944E 3488 4E85

--maH1Gajj2nflutpK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2-ecc0.1.6 (GNU/Linux)
Comment: Robbat2 @ Orbis-Terrarum Networks

iD8DBQFEWaQJPpIsIjIzwiwRAmnIAJwJWwob8g8a1FGR0B/lRFYpihXchACglqdK
Wgfl2lz8nmJvKy0KPPzPW6M=
=zwe8
-----END PGP SIGNATURE-----

--maH1Gajj2nflutpK--
