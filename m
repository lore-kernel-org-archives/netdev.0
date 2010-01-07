From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the wireless-current
 tree
Date: Thu, 7 Jan 2010 13:12:34 +1100
Message-ID: <20100107131234.4c340d1c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__7_Jan_2010_13_12_34_+1100_ktaER8VFFQYl8OIy"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jouni Malinen <jouni.malinen@atheros.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__7_Jan_2010_13_12_34_+1100_ktaER8VFFQYl8OIy
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/mac80211/scan.c between commit
8a5b33f55452c226aa0e47d737e541985ff10e16 ("Revert "mac80211: replace
netif_tx_{start,stop,wake}_all_queues"") from the wireless-current tree
and commit b203ffc3a447eb8d9e6120b783ddee081b143061 ("mac80211:
Generalize off-channel operation helpers from scan code") from the net
tree.

I used the version from the net tree (though I suspect that it may not be
completely correct).  I assume that this will be fixed up shortly.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__7_Jan_2010_13_12_34_+1100_ktaER8VFFQYl8OIy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktFQxIACgkQjjKRsyhoI8wbWwCggaXr8DrVKzJwu6P5XPsBasJD
ZR0AnR1qPiE/lKdeYVQW+YdJB1v4AOS1
=2TfM
-----END PGP SIGNATURE-----

--Signature=_Thu__7_Jan_2010_13_12_34_+1100_ktaER8VFFQYl8OIy--
