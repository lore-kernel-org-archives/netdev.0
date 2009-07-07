From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/3] genetlink: make netns aware
Date: Tue, 07 Jul 2009 23:24:13 +0200
Message-ID: <1247001854.4755.47.camel@johannes.local>
References: <20090707120835.953398074@sipsolutions.net>
	 <20090707121422.511673156@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-5YKwwZLE7KpFf+/bZm/3"
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Pavel Emelyanov <xemul@openvz.org>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:44658 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758328AbZGGVYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 17:24:48 -0400
In-Reply-To: <20090707121422.511673156@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5YKwwZLE7KpFf+/bZm/3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-07-07 at 14:16 +0200, Johannes Berg wrote:
> plain text document attachment (030-genl-netns.patch)
> This makes generic netlink network namespace aware.

No, buggy again, and again for some reason I didn't notice on first
testing :(

johannes

--=-5YKwwZLE7KpFf+/bZm/3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKU7z5AAoJEODzc/N7+QmaeawP/itF2KJw9hE+utRQLK92pYHc
ewV+t+Y+j7qrLJRT9SS07qGJ6a7m2a7iCqSHTb9rRHahNZu67jrPr8F+kmzPjFje
QKTrxw1brubAF8/azaLc/JFCL1thh6myjI7ldv7YvuszvAXNq5E+i3T782NAP6M/
H3wueJHTiqMUmTbp//hf8omOKuKyhhwotYPfYbiHAI7KX+r9y5k2jaVquzUbL1Vd
MbjEZmLzWJQ9U+PbeYxR+decKuOUWsS5kmnxEvZR0GXtIa2FkhBRU/8gJIfrY03x
MDVb2c/YRWT5bf4oMBFxdH8On3RSw8IZF6gN4ecGIcAKO1rgKESMrKIVs+Ct4xye
ar4pdtnZfKOwhhARzj0qDiUdW6UbIVVShRoKZ2Ec/YPpryReQuSO0Eynm2J+Ym1a
Wzp9oNZ3nN1k78/2uKMl4zyNwCR9+4JAh2U7W3pPLouk60JRgOOIq4BgymzsmPgm
0+TsZi1p0vo8doWpuqSs6MY+smQAWG0ev/VKKBr/lHRSwxOb0YmUT6O6PtIg+SyG
GgjuPhqF0oUA19cWnTRCCOmGxR9zkffyaocjGZdWFTfsWfmNa4Ox2GG32xiINxhN
7szZbRkshERpaGtrXXBxTwKQNxJSa9MpRUMT4dCoFBUOAkpsAPWREWEJ0Roho0WW
REYjYasD4hB+8pMcACjy
=u8J/
-----END PGP SIGNATURE-----

--=-5YKwwZLE7KpFf+/bZm/3--

