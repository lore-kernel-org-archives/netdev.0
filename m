From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net/wireless trees with the
 wireless-current tree
Date: Wed, 11 Nov 2009 13:01:19 +1100
Message-ID: <20091111130119.ace8da65.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__11_Nov_2009_13_01_19_+1100_ZR6vHQUhgK2_/neB"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__11_Nov_2009_13_01_19_+1100_ZR6vHQUhgK2_/neB
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got conflicts in
drivers/net/wireless/iwlwifi/iwl-1000.c,
drivers/net/wireless/iwlwifi/iwl-6000.c and
drivers/net/wireless/iwlwifi/iwl-core.h between commits in the
wireless-current tree and commits in the net (wireless) tree.

I used the versions from the net tree except where obvious additions
had been made in the wireless-current tree.   The fixes may not be
correct - someone should merge the wireless-current tree into the
net tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__11_Nov_2009_13_01_19_+1100_ZR6vHQUhgK2_/neB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkr6Gu8ACgkQjjKRsyhoI8w+cwCfd3itX3LiuGq2Ht1/mRw+1QSz
6SMAnRTd31/RxxVjEsNK3EQmEOxXTGUG
=0SPX
-----END PGP SIGNATURE-----

--Signature=_Wed__11_Nov_2009_13_01_19_+1100_ZR6vHQUhgK2_/neB--
