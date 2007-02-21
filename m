From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [git patches] net driver updates
Date: Wed, 21 Feb 2007 13:01:41 +0100
Message-ID: <1172059301.5080.2.camel@johannes.berg>
References: <6.1.1.1.2.20070221124144.04783fb8@192.168.6.12>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8uZ6yZfUp8/DJOwpiygh"
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: Roger While <simrw@sim-basis.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35392 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbXBUMBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 07:01:53 -0500
In-Reply-To: <6.1.1.1.2.20070221124144.04783fb8@192.168.6.12>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8uZ6yZfUp8/DJOwpiygh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-02-21 at 12:46 +0100, Roger While wrote:
> >
> >Dan Williams (1):
> >       prism54: correct assignment of DOT1XENABLE in WE-19 codepaths
>=20
> Where did this spring from ?

wireless

> I see no posting of this patch let alone
> an ACK.
> The patch is also doing rather more than the description -
> It is inserting extra breaks into a switch statement with
> no comment as to why.

The patch description clearly indicates those break statements, and
they're also clearly necessary.

http://kernel.org/git/?p=3Dlinux/kernel/git/linville/wireless-2.6.git;a=3Dc=
ommit;h=3Db5c41651645f7604dda7abc3445e1622f9b1b9ab

johannes

--=-8uZ6yZfUp8/DJOwpiygh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF3DSl/ETPhpq3jKURArecAJ9ARvg+ULnyfqDaGIl75B3p5VqJoACcC/Os
C7g7EsS8X/B+B3mdmkPytZo=
=paM5
-----END PGP SIGNATURE-----

--=-8uZ6yZfUp8/DJOwpiygh--

