From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Fri, 07 Sep 2007 21:17:50 +0200
Message-ID: <1189192671.28781.191.camel@johannes.berg>
References: <E1ITGb2-0006Be-00@gondolin.me.apana.org.au>
	 <20070906154612.GD8030@linux.vnet.ibm.com>
	 <1189171635.28781.134.camel@johannes.berg>
	 <200709071801.34909.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qm8tG29p0YzHqNLT+RI2"
Cc: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200709071801.34909.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-qm8tG29p0YzHqNLT+RI2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-09-07 at 18:01 +0200, Michael Buesch wrote:

> What's the problem with trying to lock it?

I think I had a problem with it once when I inserted it into some code
that was atomic and it all blew up badly ;) Nothing important really but
it sort of made me not like it much.

johannes

--=-qm8tG29p0YzHqNLT+RI2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG4aPe/ETPhpq3jKURAjYfAJ9HadGEto39HmJSGYkB5drHHTJMnQCeIkoW
b3tas7IMlLzntMI/l/eOg/I=
=9P2b
-----END PGP SIGNATURE-----

--=-qm8tG29p0YzHqNLT+RI2--
