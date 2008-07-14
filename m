From: Mario Limonciello <mario_limonciello@dell.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
 Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
 Problem)
Date: Mon, 14 Jul 2008 15:00:37 -0500
Message-ID: <487BB065.3020709@dell.com>
References: <4861800B.90703@nscus.com> <48777BC3.6090108@dell.com> <1216052460.23392.14.camel@localhost> <200807142152.26163.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7A1331660775F45989007665"
Cc: Kasper Sandberg <lkml@metanurb.dk>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <200807142152.26163.eike-kernel@sf-tec.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7A1331660775F45989007665
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Kasper:

Interesting that it failed for you though.  I was able to run through a
script of 200x rmmod/modprobe without any trouble when that patch was
applied.

Regards

Rolf Eike Beer wrote:
> Kasper Sandberg wrote:
>  =20
>
> Is there any chance this helps with the famous 8101 problems, e.g.=20
> http://bugzilla.kernel.org/show_bug.cgi?id=3D6807 ?
>
>  =20
>
> There is a typo in the description of 91ba1a976c214766b5ee8c6d17086903c=
10f6405=20
> (serie should be series I think).
>
> Greetings,
>
> Eike
>  =20

--=20
Mario Limonciello
*Dell | Linux Engineering*
mario_limonciello@dell.com


--------------enig7A1331660775F45989007665
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIe7Bl2CrZjkA73YsRAm7ZAJ9kFruUJ5FxB1vckOVVIpAvzUfBvgCfbWMq
kTnb0wh6taGFzP0M/+Xqmuw=
=S5Ss
-----END PGP SIGNATURE-----

--------------enig7A1331660775F45989007665--
