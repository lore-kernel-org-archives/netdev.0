From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 29 Mar 2010 19:04:28 +1100
Message-ID: <20100329190428.4a2c5626.sfr@canb.auug.org.au>
References: <20100329174300.512d83a8.sfr@canb.auug.org.au>
	<1269845561.2164.1.camel@edumazet-laptop>
	<1269845970.2164.4.camel@edumazet-laptop>
	<20100329.010104.214233589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__29_Mar_2010_19_04_28_+1100_m.bBm45rV7cSKhDg"
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100329.010104.214233589.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__29_Mar_2010_19_04_28_+1100_m.bBm45rV7cSKhDg
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 29 Mar 2010 01:01:04 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 29 Mar 2010 08:59:30 +0200
>=20
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
>  ...
> > Oops, a cleaner patch would be :
> >=20
> > [PATCH] rps: fix net-sysfs build for !CONFIG_RPS
> >=20
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks guys!

Thanks.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__29_Mar_2010_19_04_28_+1100_m.bBm45rV7cSKhDg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuwXwwACgkQjjKRsyhoI8xWegCeK3ZEemLXDkmd2zf+R6cz5Lmh
kl0AnRbPyIm7cOm1NM+SL8TmIi6ys16A
=mTm7
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Mar_2010_19_04_28_+1100_m.bBm45rV7cSKhDg--
