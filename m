From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] nl80211: remove VLAN type
Date: Thu, 16 Aug 2007 17:03:45 +0200
Message-ID: <1187276625.23489.18.camel@johannes.berg>
References: <1187169518.3960.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ePkXdZFPogBeQNKPZl89"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1187169518.3960.0.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-ePkXdZFPogBeQNKPZl89
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-08-15 at 11:18 +0200, Johannes Berg wrote:
> There is no point in trying to handle source MAC address based VLANs in
> the wireless stack, something like "smacvlan" modeled after macvlan
> should be sufficient.

Whoops. I only forgot the use with encryption. Please consider this
patch withdrawn, at least until I see clearer through that crypto issue.

johannes

--=-ePkXdZFPogBeQNKPZl89
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGxGdR/ETPhpq3jKURAoDOAKCKgkzeYX2pR4TFnZ4unHN1tnPbegCfbpT7
XHnXpUetncpeoGCX+XZIwIo=
=ylzQ
-----END PGP SIGNATURE-----

--=-ePkXdZFPogBeQNKPZl89--
