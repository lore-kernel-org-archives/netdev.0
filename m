From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: atl1c issues on 3.8.2
Date: Mon, 27 May 2013 18:43:22 +0200
Message-ID: <20130527184322.1e9aa80f@milhouse>
References: <20130312161753.281681f2@milhouse>
	<1363103144.13690.12.camel@edumazet-glaptop>
	<20130312180942.4198e88e@milhouse>
	<1363154258.13690.40.camel@edumazet-glaptop>
	<1363271460.29475.14.camel@edumazet-glaptop>
	<20130314231746.44a93e4d@milhouse>
	<1363302362.29475.42.camel@edumazet-glaptop>
	<20130315204457.21d46b89@milhouse>
	<20130322122849.72b3eccd@milhouse>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/oxvyeihr7JF20jdr7XZT0Z="; protocol="application/pgp-signature"
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"David S.Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:36678 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185Ab3E0RFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 13:05:21 -0400
In-Reply-To: <20130322122849.72b3eccd@milhouse>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/oxvyeihr7JF20jdr7XZT0Z=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Any news on this?

Am I still the only one with this issue?
It's still 100% reproducible and I can workaround it by reverting=20
69b08f62e17439ee3d436faf0b9a7ca6fffb78db

It can't possibly be that I'm the only one on this planet seeing this...

--=20
Michael

--Sig_/oxvyeihr7JF20jdr7XZT0Z=
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBAgAGBQJRo40sAAoJEPUyvh2QjYsOmYcP/iAQyB2PDEB1OBxz1pj/ZoZv
MeQp+gIYA3l1PDCi3rE6AQyZSbLBpvv0/TftTHyAEsxJyIBVNIRZ5o3uaDYXVtGS
PBx1M130YERF1Pk6IzZbUqpmI9Lhn5YH6Sd4Uv3yj+WJODupM8YRhzcxiiuBnwrY
AnLTe0ptNp2tcnapK9E8reLlXQdA9TunRQvGY9bFsfViclEJTIim4xyVIQ/ead19
CunaCzesX+OteB9mit6a2SkJ02gF+yVJ8419GM8nM+z/qbGLUEhciSmyBR31aYjs
BEFRy/oc/VY2/RCFKaYiKW2Cz8F4vZVkPBk/vCzWEp53J6n1CIUe1PuR7Epmjt+2
QtEuSbUKE1Dyhw2ByxF3zESIt9NUU9Q76UJXk3NHPzgSEfaf70iBgLDRPwZSV2tA
Yc4tOfPUFUN+OhXBJf2+WLkT2YFxgWs8/wwxtZ7N28xEaHqrmKXfyuYrKkyI0j+k
/USfKlNp/rrWh4gJimA04IlsxX1NYI3PzEJ6Toc/bfXoOExTWjGB32F+WvBCkAty
CPPTUOA1VO21/M5vg5Wk2s9sHsIVBr9G/0aIIPxzISxbF/T631GsHI498YhSicGR
olTQ8pvkCCxAgspHsnjAjgi2jt/Tx4rQNQVqQx651buES7bLxv9jNsoIOngH/WvW
F1/gITFJW3B2URPMQ5v4
=fz/b
-----END PGP SIGNATURE-----

--Sig_/oxvyeihr7JF20jdr7XZT0Z=--
