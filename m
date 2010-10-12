From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net tree with the  tree
Date: Tue, 12 Oct 2010 14:51:35 +1100
Message-ID: <20101012145135.9697fe21.sfr@canb.auug.org.au>
References: <20101012111716.0c54b093.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__12_Oct_2010_14_51_35_+1100_7QyErKK=1Hkmr6+8"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	<linux1394-devel@lists.sourceforge.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101012111716.0c54b093.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_Oct_2010_14_51_35_+1100_7QyErKK=1Hkmr6+8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 12 Oct 2010 11:17:16 +1100 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Today's linux-next merge of the net tree got a conflict in
> drivers/ieee1394/eth1394.c between commit
> 66fa12c571d35e3cd62574c65f1785a460105397 ("ieee1394: remove the old IEEE
> 1394 driver stack") from the  tree and commit
                               ^
I meant to say "the ieee1394 tree".

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__12_Oct_2010_14_51_35_+1100_7QyErKK=1Hkmr6+8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMs9tHAAoJEDMEi1NhKgbsopsIAJnOTsi3Emd4EQAE8cox++70
XOVPE+BVeTSbUrKVwAVJFqAJIfGZ1hrnKlZJQmTKJovhI/DlUb1asUhgeUhfry20
7+3V0pLWFwQbnyfwdxmsLZ0GOwEQ8tOJBWx7eXaHe+1FVpZ3JlxgRekCeoQ8x43t
tZDBH+6XyH5rZh6zf5yGv1PIKQGdI54lmycv5C4pF+ZspmzHIxPRLhWK4gpGaAWZ
8z9oIaMosPO31P04aRqtDx2c7OvSuuaB10b3v/nFoTg7Il2IhEubjemUsIpL1GKH
2pnTYccVjCBqW9uKRaZ5ug5qAyI56iyMivXnZ7NVtwM47gZRotJuLE6DtPgyhJY=
=tWBJ
-----END PGP SIGNATURE-----

--Signature=_Tue__12_Oct_2010_14_51_35_+1100_7QyErKK=1Hkmr6+8--
