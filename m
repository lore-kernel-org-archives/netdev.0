From: Christophe Saout <christophe@saout.de>
Subject: Re: [BUG 2.6.12-rc4] IPv6 xfrm tunnel oops with large packets
Date: Sat, 21 May 2005 23:49:24 +0200
Message-ID: <1116712164.10858.0.camel@leto.cs.pocnet.net>
References: <1116702611.14509.10.camel@leto.cs.pocnet.net>
	 <20050521194932.GA10959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-r3YcTXpdr+7HH7VyQ4I7"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050521194932.GA10959@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-r3YcTXpdr+7HH7VyQ4I7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Am Sonntag, den 22.05.2005, 05:49 +1000 schrieb Herbert Xu:

> Here is a minimal fix.

Yes, it fixes the problem.


--=-r3YcTXpdr+7HH7VyQ4I7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCj6zkZCYBcts5dM0RAk8OAJ9DRp4LZQvzKUY9Kux3Jv3g8ixs/QCfcFiI
U7OQVPnnX7sufwbHRT9YkXk=
=5+Ib
-----END PGP SIGNATURE-----

--=-r3YcTXpdr+7HH7VyQ4I7--

