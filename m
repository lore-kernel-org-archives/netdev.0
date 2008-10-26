From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 09:21:48 +0100
Message-ID: <1225009308.3478.22.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1KHFc+HCCgqcv6z6IjEQ"
Cc: anders@anduras.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52805 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbYJZIV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 04:21:56 -0400
In-Reply-To: <20081026.010329.11475786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1KHFc+HCCgqcv6z6IjEQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-10-26 at 01:03 -0700, David Miller wrote:

> > > Nice, have you though of something similar for IPv4 and IPv6
> > > adresses?
> >=20
> > Not really, are they printed often? I haven't had to touch much code
> > that printed IP addresses. Nor have I seen them in logs a lot.
>=20
> It would be a nice future project for someone.  But don't worry
> about it for now.

Of course, actually adding, say, %p4 and %p6 would be trivial, but
making lots of code use it so it's useful would be another mass
conversion I'm not too keen to do again right away :)

johannes

--=-1KHFc+HCCgqcv6z6IjEQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBCiYAAoJEKVg1VMiehFYSOwP/2YjTf3JGCWgJCQSBneH2GTW
DdGMaXVMEzPUO5n/VXQXp4zpuP0qcuQJ6ACGismDuRtYsqJwdyZm04Li0KKTpmtc
4/OTgNXvgisRxFaPteiUZnHRfTNy5q8KMZ3M5FaK2Naq/gkx7UXPqTVn0tz3Jlvt
wrGqjRnMFzHR7yHZmQGieN3A0w/eBMBeIzlegw+ovZbEnJEipmDqw1LqpvmoOIrs
Lk0fOVHnfhloBTYH/gC6BimLb1v4OjBYKHPFrH+aA61PSYIORso2YraIsMTqLrtf
JAYtub/oAp8MlbR1bPaB5wYcgly/eLHZRsZdpcZgPmOL9f+NY/lwmHJgwCHJkCG+
7L8g/vTtjztYGys9GWvcHXGoAfuf9fGfjzQhgSWMY5pjzfbqAJfJcPlqm2hM0tx0
z0Uz6QJPK0kxGH3ESYdO5wxA4DaKeH8MCPgX9kJXNBk6zsnZ1Ij/EM7gNywoSBah
HE1e3gBj6Dd7nGZNpPI+KPeBPW9cW7BvyMg7V6BckvIEjOVuAw0cpYKDA2rTR+5W
XZS5pwGQHuE+yhUBz1hO9eEvN5TYcvUu9QQpY+ZXBM7ncMcTEyEkmfgnB0PY6XkX
hji1493ZzhWUMZZ47lXo5zhHrnT2lLiu1uyUXxoqbbdFPyn9vKPpr7W37Op/q+9Y
FRoef/OPsH6Q8LvrFJZ2
=WJop
-----END PGP SIGNATURE-----

--=-1KHFc+HCCgqcv6z6IjEQ--

