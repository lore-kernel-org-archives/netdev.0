From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Tue, 16 Aug 2011 16:57:44 +1000
Message-ID: <20110816165744.5c069b0c9f2e329e48ecd7d0@canb.auug.org.au>
References: <20110815152048.3b8f8484faf1891ef2fce266@canb.auug.org.au>
	<20110814.225610.2264854100578866902.davem@davemloft.net>
	<20110816152815.911f15937efa2ebf58a2795d@canb.auug.org.au>
	<20110815.231116.1728582609642497613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__16_Aug_2011_16_57_44_+1000_dfhDQ7Gjl9jnTspS"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110815.231116.1728582609642497613.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__16_Aug_2011_16_57_44_+1000_dfhDQ7Gjl9jnTspS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 15 Aug 2011 23:11:16 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> Please test this patch:
>=20
> --------------------
> net: Fix sungem_phy sharing.

This fixes my allyesconfig build (and doesn't break any of the others :-)).

Tested-by: Stephen Rothwell <sfr@canb.auug.org.au>

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__16_Aug_2011_16_57_44_+1000_dfhDQ7Gjl9jnTspS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOShToAAoJEDMEi1NhKgbsq+YIAJUK5cC7nhyfBANfWvfrb9Oj
roJII11JIo3Rs/AIfqLFDgKciMFUgIOpfH9054Db2zOZKL61oB35ZMdhHIlle/6a
/FcyTs8jkZ59Jp08vEAHLOQqpb2/G9vjAupumc2q4+e17Jo5xzliNSgxCzXtFkVZ
AxUM3NAPQ1f6Y2zv+c6CgwN5KfJzKGWDuuIKNnlpg2DfZUgIpjzkj5QggAjXDeJv
QyZ81ovzXRCTmfNPvMq55YgGXfZqc13LuScISGh5vda73/ZQcrNOKLJ71V1P0Hze
gQXfAqVXARcvl18l9YDlmBA1+1T2xg2YXxYyLJDUPsYb0AQ2FXhXZ8VfKIICDLk=
=TVTP
-----END PGP SIGNATURE-----

--Signature=_Tue__16_Aug_2011_16_57_44_+1000_dfhDQ7Gjl9jnTspS--
