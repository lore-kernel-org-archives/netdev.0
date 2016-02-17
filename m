From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/2] ethtool: Add --phy_pkt_gen command
Date: Wed, 17 Feb 2016 21:08:43 +0000
Message-ID: <1455743323.21571.8.camel@decadent.org.uk>
References: <1455741436-25728-1-git-send-email-andrew@lunn.ch>
	 <1455741436-25728-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-T19Xd8Cov9L2jgKfnGoD"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50619 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965348AbcBQVIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:08:51 -0500
In-Reply-To: <1455741436-25728-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-T19Xd8Cov9L2jgKfnGoD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This needs some test cases for the command-line parsing. =C2=A0Also:

[...]
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
[...]
> +.TP
> +.B \-\-phy\-pkt\-get\-eee
[...]

...is not the name of the new option.

Ben.

--=-T19Xd8Cov9L2jgKfnGoD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsThXOe/yOyVhhEJAQpGww//ei32BYuBiNmXLneVXt8vtajKXgOYrIWJ
sYRFxHs95trkR1ZvKl9aHTzEvjXaC4TmDQCr89zEGLsEAijr5+t22TV9kjTVtkS/
6h268LuZolddhCJ87k1vrFpb7NKJ5hsWQ72ozocquiF4qRVD88Wemmtcor5y/UG1
+zM/Dn7Y8KsJS8LvVcTyivPQ97CqxMIj91n02EUxqAU5Hw6BO8ywwujZB4Sz53H6
AgH/pnRxRjj2ugUHhku3prv3J5Mf/q0JlBquBvM4qLDNagYkcFsUg+VOikNoE2Qx
e8JRucLmxuEGtGkFQEIUDnafI35+20P9wyc1pgZlUIqprqBSCPKJLeN9pJonddOX
bftJixh2tLfqmzYMlDdH9CHr+Cx8qyi+CkPns6r/01J7+Daf/Y+KS3axZrcPQqpl
K2fgnmSNdrV6OYAz0VLXATL2+en4hdTYT8y4UwybVcGmnqocb3dO8e6KQB1LM5iY
nROCbEoY5u+YqAS7HhgnGfCdQUqWn1+GcRRyRiKGfVnpIYa4MBeDHzvrmBoedX6W
q/QMmCbdvjsS9uTa0n8gOb1Xy6fIULYQcx33JVczwkgWJTxu1MHyAnzIdUrOFdn9
7HmzPevKxDCDemC4Jl2i5AJfshYT6h37DWJdFXcoNpQFWz04NIg/0h0yciut9HKM
xhybp/q0XWs=
=itZ/
-----END PGP SIGNATURE-----

--=-T19Xd8Cov9L2jgKfnGoD--
