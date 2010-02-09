From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the wireless-current
 tree
Date: Tue, 9 Feb 2010 13:24:44 +1100
Message-ID: <20100209132444.d90b48a6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__9_Feb_2010_13_24_44_+1100_FjRNGBEQufmiuull"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__9_Feb_2010_13_24_44_+1100_FjRNGBEQufmiuull
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/mac80211/scan.c between commit
c0ce77b8323c1a0d4eeef97caf16c0ea971222a9 ("mac80211: fix deferred
hardware scan requests") from the wireless-current tree and commit
af6b63741cc4e4dfd575d06beb333b11a8a6e0c0 ("mac80211: generalise work
handling") from the net tree.

I resolved this the same way it is resolved in the merge of the
wireless-current tree into the wireless tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__9_Feb_2010_13_24_44_+1100_FjRNGBEQufmiuull
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktwx2wACgkQjjKRsyhoI8zkmwCgsrQ+BwobSHu1hjXqpKgEdJyJ
y7sAnjD0WuT/lvuxpwqr1hQbF5d3WZId
=cvru
-----END PGP SIGNATURE-----

--Signature=_Tue__9_Feb_2010_13_24_44_+1100_FjRNGBEQufmiuull--
