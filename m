From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 5 Sep 2013 15:19:33 +1000
Message-ID: <20130905151933.10e0558611271fdd2133a790@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__5_Sep_2013_15_19_33_+1000_0aXG4jR=Ax4=t2Fl"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__5_Sep_2013_15_19_33_+1000_0aXG4jR=Ax4=t2Fl
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/bridge/br_multicast.c between commit 2d98c29b6fb3 ("net: bridge:
convert MLDv2 Query MRC into msecs_to_jiffies for max_delay") from Linus'
tree and commit e3f5b17047de ("net: ipv6: mld: get rid of MLDV2_MRC and
simplify calculation") from the net-next tree.

I just used the net-next tree version and can carry the fix as necessary
(no action is required).


--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__5_Sep_2013_15_19_33_+1000_0aXG4jR=Ax4=t2Fl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSKBRpAAoJEECxmPOUX5FEihEQAImLN7KDS6lMlkHq63OURAxh
5U7rO0xdhRavO95aVyYb/tWnLfxTqtpahz/eeC4tXT6k+2ob2n+4bqw3gOsRRcef
l0LzhuR8SQiOtJrGB1q4rW3aqPknpqUExsDIykqSzGULL6WlgNj1gVZ2vy9WBJZq
wXTLFadqtlGvtv7MG+g39SvGRSfKuM1Cemg9WXmPKUxf7Kc2IB823LP9Wz9QSQKo
qdhUE1E4RrJlhmLICIXtFKoDwsSa0EdQk8VTRp6Nkz73GJjskO0DIrMYBdQkupFK
OHPBnq/NLDQ7+9qgJbPYFHT82q59xvKD5Y9ywQLmp8OsrsC5Myc7FB+Jkz3LITu8
uYG7hX/8WPpFip3J67Q7gX4wCSdSQBvCGbxfTPYoepO1cJA5h9OjzeLOQTSvJAVj
+a/Htw8CX8S6LdYuTAsVNt4lfDleK68M+sl6X8Ym6KM/M3dX66P4g489mcYRbPuL
nolKuQRwIg9GjzRDYfLALxp9qXPBhyTO4unLveh5pjoi6uw40vCloPp+wlY1xBc6
81zfN4wLvShIqs2WzBK72bqsQgnrYacAmj3hzaBKHNIo9Uz+4Mf5vN/ysvhcOkrt
4jTcz7v7JrrCIj7kBo/BXb1XrNrstRBHRK1wALSx1AuUOJGoeqXNcUpH4LEI1kqN
d7QNpmAcILJSzdGRnMqv
=JPi8
-----END PGP SIGNATURE-----

--Signature=_Thu__5_Sep_2013_15_19_33_+1000_0aXG4jR=Ax4=t2Fl--
