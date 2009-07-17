From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: regression: wireless authentication
Date: Fri, 17 Jul 2009 14:10:47 +1000
Message-ID: <20090717141047.7ce77136.sfr@canb.auug.org.au>
References: <20090717035706.GA5923@martini>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__17_Jul_2009_14_10_47_+1000_7NAwRZrSTZuX2L/B"
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Noah Watkins <jayhawk@soe.ucsc.edu>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090717035706.GA5923@martini>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__17_Jul_2009_14_10_47_+1000_7NAwRZrSTZuX2L/B
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Noah,

Lets cc some people who may be able to help ...

On Thu, 16 Jul 2009 20:57:06 -0700 Noah Watkins <jayhawk@soe.ucsc.edu> wrot=
e:
>
> With 2.6.31-rc3-next-20090716 all wireless access points are detected, but
> authentication fails. I haven't verified on an access point w/o WPA.
>=20
> 2.6.31-rc3 functions fine. I haven't been able to complete a bisect yet.
>=20
> 05:01.0 Network controller: Atheros Communications Inc. AR5008 Wireless N=
etwork
> Adapter (rev 01)
>=20
> noah

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__17_Jul_2009_14_10_47_+1000_7NAwRZrSTZuX2L/B
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkpf+ccACgkQjjKRsyhoI8yRSACfW1gpH6bfQDVgjiZLb+8sqFEx
80UAn3ql/e2nB2LJLkbkFEiYlhdLF9N4
=AM5x
-----END PGP SIGNATURE-----

--Signature=_Fri__17_Jul_2009_14_10_47_+1000_7NAwRZrSTZuX2L/B--
