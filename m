From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warning after merge of the final tree (net
 tree related)
Date: Wed, 16 Jun 2010 16:30:01 +1000
Message-ID: <20100616163001.c504331f.sfr@canb.auug.org.au>
References: <20100616134848.3edd4a25.sfr@canb.auug.org.au>
	<20100616035630.GB17440@gondor.apana.org.au>
	<20100615.214406.45904170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__16_Jun_2010_16_30_01_+1000_FCbIh5YgOOfeQtjn"
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100615.214406.45904170.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__16_Jun_2010_16_30_01_+1000_FCbIh5YgOOfeQtjn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Jun 2010 21:44:06 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 16 Jun 2010 13:56:30 +1000
>=20
> > bridge: Add const to dummy br_netpoll_send_skb
> >=20
> > The version of br_netpoll_send_skb used when netpoll is off is
> > missing a const thus causing a warning.
> >=20
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> Applied.

Thanks guys.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__16_Jun_2010_16_30_01_+1000_FCbIh5YgOOfeQtjn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwYb2kACgkQjjKRsyhoI8yjXACfe4YNP9IUcImdB93/ExpMILi/
o0wAoKfmDdgXrl3ApwDu8N4n2qnHm5lv
=IuBj
-----END PGP SIGNATURE-----

--Signature=_Wed__16_Jun_2010_16_30_01_+1000_FCbIh5YgOOfeQtjn--
