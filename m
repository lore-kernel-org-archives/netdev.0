From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the  tree
Date: Mon, 5 Dec 2011 15:34:16 +1100
Message-ID: <20111205153416.e1dd01e5368ce7c016d99a59@canb.auug.org.au>
References: <20111205123428.47213da24624d85aa84711f3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__5_Dec_2011_15_34_16_+1100_/ssrxf6Sk90=A5NQ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111205123428.47213da24624d85aa84711f3@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__5_Dec_2011_15_34_16_+1100_/ssrxf6Sk90=A5NQ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 5 Dec 2011 12:34:28 +1100 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/wireless/iwlwifi/iwl-agn.c between commits from the

wireless (sorry)

> tree and commit 7335613ae27a ("iwlwifi: move all mac80211 related
> functions to one place") from the net-next tree.
>=20
> I just used the net-next version (which may require some fixes).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__5_Dec_2011_15_34_16_+1100_/ssrxf6Sk90=A5NQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO3EnIAAoJEECxmPOUX5FEjYEQAJHa2ESHSmXpnrfwmJqEco0O
pk2qM80T3xYeQfNIG15c+/iqJy1vLELesLpIckODM38/8FpQjBtd4orDB13VvCkQ
kAlXDTm6JHA5YG9DQI6FkpckkfQaUQ42uzr1NAUcGOLTGSZdbEkZoLqtnt2HAorc
ppVz+EbL8/WK5SevtwVP2qbspq/GFnIPw8129Dnpz1gBr/TKslGYz0obDTxm3B3e
eMyz+jjkF8vg6dKJ674zpdzHek5v1tPaLmfl8azgY8k6V5yfpyEsr5bin7XjrzD+
d9zQJpGU/mFx4gF2hnsmDW7zCM/cJD0hSelnWMRdlO4TYO0T2WA0WI5KuHXlUPmj
f+HJmBZQlkFkpC5PAUxfY/BqlXbFnKR+0PyqJ4k9s29I+hwjouV/dYjw57PRfkEr
j8MoofE5/FSQzpfYllj2SwNauK5HU+pS+87oFZXecz/wU83uT2T8mHSpn/bM7j6g
lhdexl2fwNh50y8v+8mfB7Vp9ZkveVvMkQGpdxQyiTs/tvdLsmBCzB6hiLe5gaIz
6unsmljaQt7J7h6RqZcsDMaNnuTKP3K1u733aYyWXaYVixdEtqenutssOyYJedys
evDLa0IftEZPuwJWlOJdT7x52mst0duRRpn/Rxz3PDKLn1nx49777AZxSoys/zTM
JR8n3yB+ynTgDE8SkmbC
=Tpql
-----END PGP SIGNATURE-----

--Signature=_Mon__5_Dec_2011_15_34_16_+1100_/ssrxf6Sk90=A5NQ--
