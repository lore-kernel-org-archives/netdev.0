From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: dscape doesn't auto associate
Date: Wed, 24 Jan 2007 00:25:33 +0100
Message-ID: <1169594733.3061.9.camel@johannes.berg>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+K1wAnjg7pijTIwxa8wK"
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56530 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965391AbXAWX0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 18:26:25 -0500
To: Jon Smirl <jonsmirl@gmail.com>
In-Reply-To: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+K1wAnjg7pijTIwxa8wK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-23 at 18:23 -0500, Jon Smirl wrote:
> I have to manually associate the dscape stack with my AP. Is this way
> the code is supposed to work? Everything works ok after the manual
> association.

Yeah, you currently need to set the channel, BSSID and finally the SSID
to get it to associate.

> Is there documentation for this stack?

Not much really. devicescape has some on their website.

> Any special utilities for it?

Nope.

> I'd like to get my devices operating in master mode.

You don't need to associate then ;) But I can't really tell you exactly
how it's done. If you figure it out, add it to wireless.sipsolutions.net
(will become linuxwireless.org) somewhere -- we can rearrange the
material later.

johannes

--=-+K1wAnjg7pijTIwxa8wK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFtplt/ETPhpq3jKURAr7IAJ40UUv4x/LgnDJXCO70e8W2p0rHPwCfXqxZ
+lasdUBNh73YgSE7GMJyLPQ=
=b5dV
-----END PGP SIGNATURE-----

--=-+K1wAnjg7pijTIwxa8wK--

