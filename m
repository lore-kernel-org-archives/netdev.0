From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net tree
Date: Wed, 3 Feb 2010 13:30:11 +1100
Message-ID: <20100203133011.75aef1d3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__3_Feb_2010_13_30_11_+1100_lIVWeu2jSe7VAYf5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Daniel Mack <daniel@caiaq.de>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__3_Feb_2010_13_30_11_+1100_lIVWeu2jSe7VAYf5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
drivers/net/ppp_generic.c between commit
fa44a73cc766c7f3bac71a66d564e0049b800325 ("ppp_generic.c severly
whitespace damanged by 9c705260feea6ae329bc6b6d5f6d2ef0227eda0a") from
the net tree and commit 09e1aa00f106a476f5b90d94fc0139544bbded75
("tree-wide: fix 'lenght' typo in comments and code") from the trivial
tree.

I fixed it up (by using the trivial tree version) and can carry the fix
as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__3_Feb_2010_13_30_11_+1100_lIVWeu2jSe7VAYf5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEUEARECAAYFAkto37MACgkQjjKRsyhoI8yWZwCWJMtR11j7PMNbRc1ldjzdmq/Z
dQCfcjCwywcKvRPISQARfJCB+YrIetU=
=HoeT
-----END PGP SIGNATURE-----

--Signature=_Wed__3_Feb_2010_13_30_11_+1100_lIVWeu2jSe7VAYf5--
