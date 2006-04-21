From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 22:29:29 +0200
Message-ID: <1145651369.3897.33.camel@localhost>
References: <20060421201147.D4F76482CF@silver.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/S6qeV73VmQ1rPUXtKJp"
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55687 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750745AbWDUU3c
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 16:29:32 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060421201147.D4F76482CF@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/S6qeV73VmQ1rPUXtKJp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-04-21 at 22:11 +0200, Jiri Benc wrote:

> Also, "soft" and "hard" monitor modes are introduced.

What's the distinction? The code might want some comments about what
that

> +       /* Device is capable of performing full monitor mode even during
> +        * normal operation. */

actually means. I suppose it means that the device will receive control
frames too, but I don't know if that's right.

johannes

--=-/S6qeV73VmQ1rPUXtKJp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARElAp6Vg1VMiehFYAQLwwQ//QN9iTWx7Jqo8x9gw+LTXD29i5MXRf3NE
j3OWD1aQiLGPm796uFPYbGJiYtdCpsXG/K+5XzOjuxgGbIO2HWHulXGkVUJkA3xM
8V4Lt4RBgPujdbyMQHI28ySVI8j1Mbvs+nZ8I7olF7VYDgbO1x/bii2n7kv5D+PX
YyDJn72mtAbUyqNIidKzahN6+xCfbndZ1s+tgQb+iLtdHLWv93Mmy5jn06EVxIBo
89dnXjaOTJ5/md/aWjHWXzX6ktaWikD1EKoqWDNpbTrz/m3C4AtxgraEWzYyu9Hv
eq/rhiDqOy+YRYp7uoN9+Kz6Emwyq/isDBW6J8jcHigB/yGD/bcDsgna3y9Xu5Eu
74dScnr2c4SJDzn2mwZbJvgIUQb/h5t8uureGxKDBdkRfkWRzY9fiEofBpDF2ZRt
ygi09jKgLTWJE4z1gELtHyFougvutSQaVMQdghdDHaSVgru9wCMn1X4TKkd8/X0k
CtuKz6nDeXc+M4amKEq8+3tOrS0o4YiMqt1Jq52mzXbQvrtF82HS/Xda/kxNT6Rv
wJDkiy59VmHi7yLUalJfdOCJ9xd1qXLWkVR871A9xazgz57fQeqbb0mcQYimDL+W
LnuwDY6cNExW8aqkGl84EwbAJPAti/3g64vNbv+IxnH7KNfiil2EJkvVTmESR/eu
grLsP/O513Q=
=AMV6
-----END PGP SIGNATURE-----

--=-/S6qeV73VmQ1rPUXtKJp--

