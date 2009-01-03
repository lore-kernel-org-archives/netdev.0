From: Mck <mick@semb.wever.org>
Subject: Re: bnep module in 2.6.27 fails to provide bnep0 device
Date: Sat, 03 Jan 2009 12:24:44 +0100
Message-ID: <1230981884.6118.5.camel@localhost>
References: <20081229131222.5C2902F889@sch-sesat01.dev.osl.basefarm.net>
	 <1230945613.10187.13.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-oYfMULWbRG1j7CCfxtsq"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:56599 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752982AbZACLZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jan 2009 06:25:21 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1LJ4d5-00079M-1s
	for netdev@vger.kernel.org; Sat, 03 Jan 2009 11:25:19 +0000
Received: from wever.org ([83.243.151.80])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2009 11:25:18 +0000
Received: from mick by wever.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2009 11:25:18 +0000
In-Reply-To: <1230945613.10187.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oYfMULWbRG1j7CCfxtsq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

> Then running "pand -c XX" I get:
>=20
> [pand] Connecting to 00:19:63:14:8C:6C
> [hcid] link_key_request (sba=3D00:10:60:D1:7C:31, dba=3D00:19:63:14:8C:6C=
)
> [pand] bnep0 connected
> [/etc/init.d/net.bnep0] ERROR: interface bnep0 does not exist
> [/etc/init.d/net.bnep0] Ensure that you have loaded the correct kernel mo=
dule for your hardware
> [/etc/init.d/net.bnep0] ERROR: net.bnep0 failed to start

Sorry, i see now this list is a development list and my post is user
orientated.
I came to it via gmane.org and read posts that /looked/ user-like.
apologies.

~mck

--=20
"The shortest and surest way to live with honour in the world is to be
in reality what we appear to be." Socrates=20
| semb.wever.org | sesat.no | sesam.no |

--=-oYfMULWbRG1j7CCfxtsq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAklfSvwACgkQkdPrePiuutMgDwCgjnYVlr4SIiedn+rnLY8wYhgT
11QAnRjIXA7zSZQ+jXBJIpVz5JVe82eL
=nkBF
-----END PGP SIGNATURE-----

--=-oYfMULWbRG1j7CCfxtsq--


