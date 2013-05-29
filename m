From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net-next tree
Date: Wed, 29 May 2013 12:33:17 +1000
Message-ID: <20130529123317.5523988bebf0b9a19d04e53e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__29_May_2013_12_33_17_+1000_vwwtKaJgG/nXr/er"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anatol Pomozov <anatol.pomozov@gmail.com>,
	Masanari Iida <standby24x7@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__29_May_2013_12_33_17_+1000_vwwtKaJgG/nXr/er
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
Documentation/networking/netlink_mmap.txt between commit 3dd17edea018
("doc:networking: Fix typo in documentation/networking") from the
net-next tree and commit f884ab15afdc ("doc: fix misspellings with
'codespell' tool") from the trivial tree.

The fix in the net-next tree was a superset of the one in the trivial
tree, so I used that and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__29_May_2013_12_33_17_+1000_vwwtKaJgG/nXr/er
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRpWkHAAoJEECxmPOUX5FEBdwP/A+By50J/4vbc0Gfji9No6gy
Ch3Pf3UBhB3fogxSvDtlFtoAC9+OQaea79Rk1jPuTXMpSQ/Fg0HYTwjzqztasdfd
in1uu4q8dUpNI2PayS+Ip4hE5e1mPz0fEkaAPV0Txs7JbCj5S6MeEcawCiWfJVY9
d8f+IJjXziH8MZs7q8fUf73f1H2nzQl5pAsMOI9FL/Q6mALGu4wRdvPg+y7830UM
4yQ43ILta1BGAXVypiPBVvbNI6uCKH2sM7WwQZTc1VgMEbnW+rDQVL2rzeDENH5Q
KDJqIbf3m6j1WwoD4EQ823RTnNAuhODwb6ln+fEMH+g8Cj/S6oaDFbL0PyH9SBfh
Q5LOLiRIDli8PDuvWgylWZDAMZZ8G7cH97jsYtLwcJESPWhLMHvbCUOnZqUCf2xQ
LpGc2ginSDtE0mSXlktDf61zJYZmoOLD3OT61R33nkYqp3BHFObdSkIpiEbbT/pM
4+nBEJqQSdsPxqUPs6A4dXg2Fj+wHWzE8vd+9Lqzg+0+1Tx+CypBF0bLFghhtgSI
/gBk1lhwAjVg0YIpbbM2Bb6pb69hktxTqhv5N3BeKGfimVZhvV4Ixwz1+1lzD2LH
J9bnuZSjFgUFjaOYofCdoVBYwerGzLiR/pSjAz/z0EemdGxPIkspCldAVun8mHob
LgbeGil+Oi+oE0sONYhw
=a1F1
-----END PGP SIGNATURE-----

--Signature=_Wed__29_May_2013_12_33_17_+1000_vwwtKaJgG/nXr/er--
