From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softmac: semantics of SIOCSIWFREQ
Date: Mon, 17 Apr 2006 22:19:22 +0200
Message-ID: <1145305162.4116.16.camel@localhost>
References: <1145190888.6560.22.camel@localhost>
	 <20060417163759.GB28203@bougret.hpl.hp.com>
	 <1145299691.4116.11.camel@localhost>
	 <20060417190649.GA28534@bougret.hpl.hp.com>
	 <1145302029.4116.14.camel@localhost>
	 <20060417200139.GA28626@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0+dZ0bPrMRX+ZNm6wGP8"
Cc: netdev@vger.kernel.org, softmac-dev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:12453 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750893AbWDQUT1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 16:19:27 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060417200139.GA28626@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0+dZ0bPrMRX+ZNm6wGP8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-04-17 at 13:01 -0700, Jean Tourrilhes wrote:

> 	Who sent the beacon is different from who created the IBSS. If
> you don't like this proposal, here is another one : if in ad-hoc mode
> the actual IBSS freq is the same as what the user set, then set the
> 'fixed' flag, otherwise report the actual freq without the 'fixed'
> flag.

I don't really see the point of this either.

> 	Or if you have another meaningful use of the flag in ad-hoc
> mode, just shout.

I don't have any meaningful use for it in ad-hoc mode at all :)

johannes

--=-0+dZ0bPrMRX+ZNm6wGP8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUAREP4SKVg1VMiehFYAQLEZg/+PTbytE03SYuMKmDF6TlkG5fMiSSrliV2
RB+hQwjhyqDZ8Pjr9f55d8oGyDdO9vJBDCJA4lmpE3F9gFpJ9fI2m5ZfGCDE1v2q
t2AmuhO9s2IkptpOJsUSC1JoLQjdYqOk9rO2bNeJwE/rrT2MOtiCBnXr9GwW/xqG
aCbWCUo5pc9B+7RbuDBFUz8qwQ/LfrJ6zJo6aMqRcq6t2g4HjW3OC8p1w+5CJaAU
u2aaGyjg0ouygDer4CsbFxh9ulEZwTPhRXbcjfOpMFCcirh08FDV4wPOtgIno3bk
hNHBeDIVo0njcDJDHmxfYxDc9w4FFtJMBCyS1Fk1M1L82DT5jClQWI0ORjfbwGJH
uLOLVRdj+C6dWSBTV60ir0oEJROq4E/Mp/RZ1TIq0NsMlrd92pwyfAPuPdjJDgB7
z4LvrX9OuKLiR7AXXFzjz2FlOmfXVNDJrmPhyKZZWQ5hLUNW4PXFJ8qdog1MSryj
RplEZ4JE88E1SJcJRgO4tcy3DUy3X2+JGB7EaL45L7DpdbPesUIovuJyVlGoJ/3M
rHqpXqHG8INahA/LJ7ruDI0fq5yhDTrxl4wvSjwV0TI3Mq/S4IanpUUf2rsIaX06
FPLs5YSje6EwCZIycLkuLm2mt+rgd+6NW9nFczCLdiR9nug3Iljpsi9r2UAHdBtb
8BORCvhzhrI=
=rxlQ
-----END PGP SIGNATURE-----

--=-0+dZ0bPrMRX+ZNm6wGP8--

