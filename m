From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Remove CONFIG_NET_WIRELESS
Date: Mon, 15 Jan 2007 11:24:28 +0000
Message-ID: <1168860268.3344.0.camel@johannes.berg>
References: <45A91414.40107@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QGubCmUd0jIOFJv0aiIH"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38141 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932226AbXAOLYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 06:24:49 -0500
To: Maarten Lankhorst <m.b.lankhorst@gmail.com>
In-Reply-To: <45A91414.40107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QGubCmUd0jIOFJv0aiIH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-01-13 at 18:17 +0100, Maarten Lankhorst wrote:
> Remove CONFIG_NET_WIRELESS
> Nothing uses this, and it breaks the kernel build if a wireless device is=
 used with a unsupported type of bus.
> Verified this with a grep.

I don't really care about the symbol and I'm in favour of removing it if
it is useless, but I don't understand the rationale. How does enabling
this cause anything to fail?

johannes

--=-QGubCmUd0jIOFJv0aiIH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFq2Rs/ETPhpq3jKURAq15AJ9um00kw05ZLaWftt2IgsQTGRMVOwCeMf6u
w1y94PgyOH7KX96bAh5kQmw=
=JgHA
-----END PGP SIGNATURE-----

--=-QGubCmUd0jIOFJv0aiIH--

