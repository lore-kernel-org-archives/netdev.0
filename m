From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warning after merge of the tree
Date: Sun, 4 Apr 2010 17:26:05 +1000
Message-ID: <20100404172605.098eb8ad.sfr@canb.auug.org.au>
References: <20100329103139.1a735227.sfr@canb.auug.org.au>
	<20100328.185707.161194820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sun__4_Apr_2010_17_26_05_+1000_ouKpu5uhsFq5sqW+"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kyle@mcmartin.ca
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100328.185707.161194820.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sun__4_Apr_2010_17_26_05_+1000_ouKpu5uhsFq5sqW+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Sun, 28 Mar 2010 18:57:07 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> Strange, it didn't warn here.
>=20
> I just committed the following, let me know if it fixes
> this.

Yeah, that did it, thanks

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sun__4_Apr_2010_17_26_05_+1000_ouKpu5uhsFq5sqW+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAku4Pw0ACgkQjjKRsyhoI8zU5ACdGMLv3IV3wVDr0W4XvCF2S9KD
VpwAoK6flZ40PViuzZuh/TD2on9axKtf
=omtc
-----END PGP SIGNATURE-----

--Signature=_Sun__4_Apr_2010_17_26_05_+1000_ouKpu5uhsFq5sqW+--
