From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Kconfig warnings on latest GIT
Date: Thu, 10 May 2007 17:39:29 +0200
Message-ID: <1178811570.3806.18.camel@johannes.berg>
References: <200705080004.14570.ismail@pardus.org.tr>
	 <20070508143127.38fafa3c.kim.phillips@freescale.com>
	 <4640D988.1040504@freescale.com>  <20070510051042.GA16812@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3bQchR82OfYt+AOLlfWa"
Cc: Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?ISO-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>,
	Kumar Gala <galak@kernel.crashing.org>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33863 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930AbXEJPhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 11:37:15 -0400
In-Reply-To: <20070510051042.GA16812@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3bQchR82OfYt+AOLlfWa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-05-10 at 14:10 +0900, Simon Horman wrote:

> drivers/macintosh/Kconfig:112:warning: 'select' used by config symbol 'PM=
AC_APM_EMU' refer to undefined symbol 'SYS_SUPPORTS_APM_EMULATION'

Argh. Is that with ARCH=3Dppc? I keep forgetting that it still exists,
sorry.

johannes

--=-3bQchR82OfYt+AOLlfWa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGQzyw/ETPhpq3jKURAuMwAJ41EKy0sU4c2KQg82PywbUEia2SkwCaAynC
f27703LSTmqVHAvGfsFqNgw=
=+vWV
-----END PGP SIGNATURE-----

--=-3bQchR82OfYt+AOLlfWa--

