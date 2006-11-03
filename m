From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] d80211: add a struct device* hardware property
Date: Sat, 04 Nov 2006 00:46:19 +0100
Message-ID: <1162597579.3738.0.camel@johannes.berg>
References: <20061102223854.692274000@sipsolutions.net>
	 <20061102223854.692274000@sipsolutions.net> >
	 <20061102230015.555750000@sipsolutions.net> >
	 <200611031727.41131.flamingice@sourmilk.net>
	 <1162596074.24673.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pLHU6ORTOrBYfQSdXjyw"
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:45796 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932486AbWKCXrx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 18:47:53 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <1162596074.24673.16.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-pLHU6ORTOrBYfQSdXjyw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2006-11-04 at 00:21 +0100, Johannes Berg wrote:

> Actually, it is used for all new devices as well. Yeah, we could pull it
> out of the mdev again,=20

Oh, in fact, we do. I still think it feels stupid and will change it.

johannes

--=-pLHU6ORTOrBYfQSdXjyw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUvUyqVg1VMiehFYAQIwrA//d7rjyTuA9MNJg6sIr8buD3pInDGoH6AK
9/3/yaA+GNpkmKwXYWf5EVCqVccrp1ZcdFsRsUO0RiJ6VmHg404nGrT2PZoU0jYL
OieMZyF38mim9sUheFqjcmRnvKNM5Typ3pGZzAhOw6dRlvXcmxWz9sAwA5Q5tkrp
h7XljMwzo18INkHdvLbxSr5uNaMI5vJp9zIx/cjRHE34YSbSoAzhmpOqMpKqrb/V
0gpoMRGzKbA1UMhJn5sdeB68SaFhCe949OACBSYQqSaC79OknEr3vJGUn9BmUiqj
YIkX4QW4LBtPwygFCZrexnocdtjKPspzV9F7IS5e5AdkqgfbkoQgcGnwb1tW3/Wm
Dnum/8duMTkbtPN1nV84f5cVCV04usK3jz/wquRExw875w9K1DWS6WLaKCIm1Tsg
KbwyFl24poksdzXqGyCt3ECszzQiH4EDWWpmJA6RpBrw2w+3/8a5QsqMDdfHb14Q
gw9FhjMeWWVf1fakNPlgePAlRXvSEztS9YOPM6I8+XZpOf3THKOyUxKbKshrWeLX
RQQtc9TVymAz3LKMmZWDduGzOW9lUbje1xztk/j3coLcAOiIOjmO9LTDpqWZv0F8
pn0S24PeeoaQlwiKl0piC6N569qdbC9/8oIXQ27tWlsCE+4oW1UM/nq7MPhMbraF
yLdNXvLJSaU=
=On85
-----END PGP SIGNATURE-----

--=-pLHU6ORTOrBYfQSdXjyw--

