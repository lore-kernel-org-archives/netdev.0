From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch] at76_usb wireless driver
Date: Sat, 03 Mar 2007 16:09:48 +0100
Message-ID: <1172934588.4966.46.camel@johannes.berg>
References: <20070110145724.GA4171@bogon.ms20.nix>
	 <20070223221230.GA9965@bogon.ms20.nix>
	 <20070303150029.GA19940@bogon.ms20.nix>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cm3GG6m5wEiypEDQK5dz"
Cc: netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Guido Guenther <agx@sigxcpu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53919 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030305AbXCCPKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 10:10:13 -0500
In-Reply-To: <20070303150029.GA19940@bogon.ms20.nix>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cm3GG6m5wEiypEDQK5dz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Pavel should know better and have told you that wireless got it's own
list ;)
Quoting fully to make linux-wireless aware. I guess we'll want to take
out netdev on replies to this.

johannes

On Sat, 2007-03-03 at 16:00 +0100, Guido Guenther wrote:
> Hi,
> I'd be glad if someone could review the at76_usb wireless driver, it
> adds support for the at76c503, at76c505 and at76c505a wireless USB
> adapters. Since it exceeds the lists size limit, please
>     git-clone http://honk.sigxcpu.org/git/at76c503a.git/
>=20
> The projects homepage is:
>     http://at76c503a.berlios.de/
> The above git tree is functionally equivalent to the CVS version at
> berlios but removes support for older kernels, older wireless
> extensions, C99 style comments, commented out code and shifts things
> around a little for better readability. This is only done to ease
> reviewing - there are no functional changes over the CVS archive.
>=20
> The driver was tested (and is in pracitical use) on at least i386, amd64
> and powerpc.
>=20
> Please note that I'm not the author of the driver, the driver itself
> lists these copyright holders (but none of them showed up on the
> mailing list during the last couple of months):
>=20
> Copyright (c) 2002 - 2003 Oliver Kurth
> Copyright (c) 2004 Joerg Albert <joerg.albert@gmx.de>
> Copyright (c) 2004 Nick Jones
> Copyright (c) 2004 Balint Seeber <n0_5p4m_p13453@hotmail.com>
>=20
> Pavel Roskin, Maxim Grechkin and me were committing to CVS recently.
> Cheers,
>  -- Guido
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=-cm3GG6m5wEiypEDQK5dz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF6Y+8/ETPhpq3jKURAicpAJkB5NTfipYJJcGOTkaj5uvYTThz5QCfd4wT
WoILie/5wQ8RNV3v4bAQRos=
=BQIh
-----END PGP SIGNATURE-----

--=-cm3GG6m5wEiypEDQK5dz--

