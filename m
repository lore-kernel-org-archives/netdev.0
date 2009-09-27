From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [bisected] Wireless regression in 2.6.32-git
Date: Sun, 27 Sep 2009 20:46:39 +0200
Message-ID: <1254077199.6583.8.camel@johannes.local>
References: <20090927151855.29efcc53@infradead.org>
	 <Pine.LNX.4.64.0909271708210.8927@sister.anvils>
	 <20090927204548.3ee3768f@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-ldW/tT5iPJg4gQjY0zWE"
Cc: Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090927204548.3ee3768f-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-ldW/tT5iPJg4gQjY0zWE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-09-27 at 20:45 +0200, Arjan van de Ven wrote:

> > Subject: cfg80211: don't set privacy w/o key
> >=20
> > When wpa_supplicant is used to connect to open networks,
> > it causes the wdev->wext.keys to point to key memory, but
> > that key memory is all empty. Only use privacy when there
> > is a default key to be used.
>=20
>=20
> indeed it does
>=20
> can we get this into mainline soon ?

John's on his way home I suppose.

johannes


--=-ldW/tT5iPJg4gQjY0zWE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKv7MLAAoJEODzc/N7+QmahfEQAK2zHs7KsytW5OP0rI3htT7h
BOKcw5vt31Yd0koH3mM1jPCCnwqPubQORSezFOiyz+Ff7kvwnh0sG7lrp3CQUOW7
NzxEwOYDt8ytTbuLQZzwThxeN7EGgZb9qKRn8CUhcnXe3BnuQmGLH6th7Xqhx19q
2lNJKxR7HhP8EGHNLnYr2Mgh4MXvRjyZd0BiXBShgaE+6ahPZ4JZV0wKgH5HVio8
1w9wSI5VxYkLXajTJQTke2KAplvl435ghYxGpzUymhwoxW1/LRURccg3ykDvUzxA
qxrxlQo0B50uLwh3+xKn+AodyBc4d/5B4dRi4Lunj0dcEWg/zpBIwjKrTBmZFMMj
SfQlnnDW21+JjiSw84ArHkKZeY1cfDWQZhAoTcZskL430XCthYzchQO3v4DrqI0A
jY7jomVtBVRK0k8YHTFhxYwTZUebVNL3VAF9V4+a/4a0H2KLu2EIYQCILg5fR4pe
plfe1ypmmzqa89hcfrTqVztAFaxfRvPeulRy8T4TEV6ihkxy/3lh8juM0vgQ5jRv
86f3/GmB4jr9nc+apXnh9MiejTYKdQkqAkUGzpcympAxTOo9JS1C45PZmVWXSkeT
xTubNhGR/h17DeBrSrv6zDnDlOplZik4dFlCfMzdbm5YbRCA5pXiQx7kshxofH9+
HvGCEiQjpYhD59TM1s/k
=3Kuu
-----END PGP SIGNATURE-----

--=-ldW/tT5iPJg4gQjY0zWE--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
