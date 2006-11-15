From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Setup of testing lab and work on development
Date: Wed, 15 Nov 2006 19:15:54 +0100
Message-ID: <1163614554.5399.112.camel@johannes.berg>
References: <d9a09df00611150857i3ac7e35cr84dd61cfd55f5b4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3L24mWD1d0ywg2EjpAdZ"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:22423 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030796AbWKOSRf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 13:17:35 -0500
To: Udayan Singh <udayan.singh@gmail.com>
In-Reply-To: <d9a09df00611150857i3ac7e35cr84dd61cfd55f5b4e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3L24mWD1d0ywg2EjpAdZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-11-15 at 22:27 +0530, Udayan Singh wrote:

> 1. if i understood correctly.. The discussion thread : "wireless notes
> / pre d80211 merge" discussion applies to the directory "net/d80211/"
> from git:......

Right. I CCed you because you seemed interested in d80211.

> 2. Test environment to setup for d80211 would be like this :
>=20
> Laptop (Centrino - with ipw2200 or would it be some other) <----> PC
> acting as Access Point (with Wireless modem)

no, ipw2200 doesn't do d80211. check drivers/net/wireless/d80211/

> Any other that you would suggest that would be a more reasonable test
> environment setup ?
>=20
> Also if you have suggestions which company of appliances i should go for.=
.

What do you want a test environment for? That's the key issue. I have a
bunch of wireless hardware and an access point...

> Few points that for clarification.
> 1. I intend to do the same so that I can also check if I make any
> changes how are they reflected. I hope my purpose would be solved with
> above setup.

Not sure what you mean? Do "the same" what?

> 2. How frequently would there be changes required in h/w here ?

Umm, never?

You fail to state what you actually want to do...

johannes

--=-3L24mWD1d0ywg2EjpAdZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVtZWKVg1VMiehFYAQJlfQ/+LqTpWmjAtp7mpwtzpNFlvybMRp5sMCHu
17sg/BzVdum8fiFrMgXAoRmxR6YMVqgFWelifw3IbIF1DnV6qUD4whCj0Ng0E/4Y
7DMKEeMKSAsbkpHUg9vaBJkOFTzFDEM50sXMCgiGxX6tU5/iylzIXTTg0fTIf1+R
S6htOd5x5/Alwf5eMlUa+9PUq9Gq8OHl2hx3D3iD4P7VZ20CX23fhifmaXB8rTSE
I01GOvAEhh7PNcON3iyoNzzREi6nP6JFADypDKB1Fi2wVP1lkXhS9zjQ1NrCwcps
828ROaRS82fCWDhIqkkS59dvn8Bd9whCg1gBVIMkvRZfJad0v71KS9izA+8nEZkj
7ruDrEIgANk9V9nFj4+na0MEF6i/xRaB7eQKVLpfRrKlMCI0UugXOzxUyefImPgD
Ao+eVwlJTSy5BlCwETBZLJVEiX1nOFYD5hKPU3u7Q9wexK/EMxKiSIO4w+ztzzKs
z5hSFsCK71cWZ3o3cPOIUBckPoLXRX39ZpWn2FZKYVV9iapiSjf04tbhZZD8DT/g
9EadH+09eMEAY/V+EaNkr4Jj5LEqWWN57MFlhcpcc9qZg2tD2gAq3m8zRlvKzxTn
YXcz6DJwdCIUEK4Xg3lI0EaDcRroQqkGsxWULMBpcD3/GMe3QFdahwfHOu0Ocmep
YyiFkIhT+S4=
=G/KI
-----END PGP SIGNATURE-----

--=-3L24mWD1d0ywg2EjpAdZ--

