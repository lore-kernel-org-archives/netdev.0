From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 01:32:41 +0200
Message-ID: <1161646361.3942.21.camel@johannes.berg>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-u8pvoLEz/1DUxaVu3m7i"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:16515 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932295AbWJWXd7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 19:33:59 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-u8pvoLEz/1DUxaVu3m7i
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-10-23 at 18:41 -0400, Luis R. Rodriguez wrote:

> The current setup on d80211.h makes regulatory domains device
> specific. I believe this should be changed to be stack-specific --
> that is, all drivers adhere to the restrictions set by the stack's
> current regulatory domain.

There should be a way to have a certain device restrict that even
further, if the driver wants to allow operation only in a domain that
the device has been certified for (because it may malfunction otherwise,
for example).

I'll probably have more comments later, really tired now though.

johannes

--=-u8pvoLEz/1DUxaVu3m7i
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUART1RGKVg1VMiehFYAQJe+Q/8D97laMazeBVN/HSaLO4wdXnjsAz2xaxw
Dsi6F+y+b+OiUoPxFEG4r6KRpvECNhkBWyTQOLqOLnkaEw03aAY1KKDfRiOAADl+
cW2djWZIm84L81VmApZayrHe9jYaj8wJHoFORMfYwd1pFnA7hoxCi5JtVEBdBUtI
uz6tVjouQfATYg1Z5yBy+pli5OWdBpmeqDLJoCVoIA3/FvFxkSORLcddyk0y1z47
smuGW/v+TT/3DKEjvpwKvpA55JSznVwKNS7M6L8uYp8+cFpgvqAXhBpBHr0Xx+4l
Bm71qAnMGA52oFNonYtOznvVQ9Qm5Usk0L+ZJq9VNPJ8tQIY1zDlXErx1needUdu
A+3ZREp/25rZyzOONhldNINzMpkZEk47IFgiApxWTmhkF41ki8eC3KQfI3M3X78V
TkYKx7pGVqK6s2TFb+WDzCOZ2qXNdExY1AWSi3Ca+c0dvjGsHc28BsT6P2jPllb9
emMA+m2ZOWhtVfxQbQ7XpCGRalGevrMf9SpY2bsyCbZ4AM9lmz7TcV08o67AnC22
P8cQC9g/k/pcM/UkZ7zV/Xxb9loddtzNacY6M/pQbKtiTN8ToNJpRCdjaHIFk9dI
XOF1l7gkpJoD/Q6ID0epEQvm87V8TscJSWVU5uh0pC4gRVJWIDd2hhHLeM/jsjyZ
64mWHV3M9+8=
=t9nA
-----END PGP SIGNATURE-----

--=-u8pvoLEz/1DUxaVu3m7i--

