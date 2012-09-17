From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Sep 2012 01:15:34 -0700
Message-ID: <1347869734.2093.7.camel@jtkirshe-mobl>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120917.005636.200884862654234164.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gltI7yBjSHmquWo1tIjt"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26011 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752Ab2IQIPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 04:15:36 -0400
In-Reply-To: <20120917.005636.200884862654234164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gltI7yBjSHmquWo1tIjt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-09-17 at 00:56 -0400, David Miller wrote:
>=20
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 16 Sep 2012 21:15:34 -0700
>=20
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> master
>=20
> Sigh...
>=20
> You changed this tree.
>=20
> It originally had the IGB PTP changes, which you asked me to
> reconsider.
>=20
> So I went to pull them in and now it had these new changes in
> it, which I accidently pushed out to net-next instead of the
> IGB stuff.
>=20
> Never do this.  If you wanted me to consider to sets of
> changes seperatedly, put them in seperate branches for me
> to pull from.=20

Sorry, I had not heard anything after several days, and since there had
been a number of changes to the tree since I last sent out the push
message I was going to re-sbumbit them against an updated tree.

I will put together a branch with the igb patches now.

--=-gltI7yBjSHmquWo1tIjt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQVtwmAAoJEOVv75VaS+3OdicP/j460c8B8hzakBv3c5yubRM7
G8bo42iF0ePHWtCFxF4nWAN4yoe/GXKiYaKGmHrt4vJU/m0FBU4UfpRf5qym7IMg
OFoC2xKxxGd+AE7HPkaihLNuU8WRj0fOtl5+rv8R4qJYP4fFL2VEqovC6kXR7xDf
/Yc03PT8aYAMKdPm6brpvmWwbetr+OkqzsZqZNmQR7SMU0kNtJcexH4xNR9EXZXe
KKHuUW/efHYgm9TqNcJ4k8drr9Wrx1TFeWvLGtVDypcIIi33riwTi6alrI5JV7Aq
eSggyN5aoh3xCMWVSihuQF7PqA3hxPl/4GIkxQShHNbvvqVZ49CQEaOg4T05hd1M
wMGkondjmYkMXTNlXxTYuAXsN91zmLpcGauc7YRFO2c8UHY/sYeLIHkIQ1tuo4Ts
ZZ9Cg/2t7qKifFImLTlO8VQMQMO9jtJoOaC5UgoqPJjKI9fPvBwwO4iTrmwqYdzM
6OgQnvkBfSxo9eTAgz3yiik2AWUlQhOiCHuC11OvOoZX2jV0Y/6ya3SNeOxda8TR
pR0xecWc7/29me32hTFmkCquDV3Dc1benVId8f8zluu42jwSNK2GC0hdh/5tf2NX
8VodyyN9kEhTEflYhuk9bshKZAj5aOK99adJSkeQ/6LoZNDBP4c2ImOiKGof1bq9
unS+K6Us9y6aGGU3zPw0
=zUOk
-----END PGP SIGNATURE-----

--=-gltI7yBjSHmquWo1tIjt--
