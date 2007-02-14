From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Wed, 14 Feb 2007 14:18:10 +0100
Message-ID: <1171459090.11116.22.camel@johannes.berg>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
	 <45CCCAE1.9080901@lwfinger.net> <20070209213239.GA11650@srcf.ucam.org>
	 <200702100655.51495.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rEspaolx7Cr6qpw+rgR+"
Cc: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
	Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200702100655.51495.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-rEspaolx7Cr6qpw+rgR+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-02-10 at 06:55 +0100, Michael Buesch wrote:

> It's likely that old cards still work with v4 firmware,

No, it's absolutely impossible. Rev 2/4 cores have a totally different
instruction set in the microcode.

johannes

--=-rEspaolx7Cr6qpw+rgR+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF0wwR/ETPhpq3jKURAmfzAJ9AhQiN8fAYEbbUGc3rZnh3pJz8gACgi67r
cysrzMguMMuwFKfOg7Bkhds=
=0F/a
-----END PGP SIGNATURE-----

--=-rEspaolx7Cr6qpw+rgR+--
