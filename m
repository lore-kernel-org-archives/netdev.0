From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 2 Oct 2012 11:51:17 +1000
Message-ID: <20121002115117.e13fe5efd765117d513c60de@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__2_Oct_2012_11_51_17_+1000_kz5QJZ6tkGNGMWb."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:58647 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715Ab2JBBv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:51:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__2_Oct_2012_11_51_17_+1000_kz5QJZ6tkGNGMWb.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
Documentation/feature-removal-schedule.txt between commit 9c0ece069b32
("Get rid of Documentation/feature-removal.txt") from Linus' tree and
commits 965505015bec ("netfilter: remove xt_NOTRACK") and 7b55279f6a45
("NFC: Remove the pn544 raw driver") from the net-next tree.

I removed the file and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__2_Oct_2012_11_51_17_+1000_kz5QJZ6tkGNGMWb.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQakiVAAoJEECxmPOUX5FEeHsQAKii9OPf4Fane16Lqj8Wb0rM
yDZ3EuUqc94uXE0ZiOoaRt9aMCO57HnHQvlSkPDLuoeXshy2pkSool2diAWAh5I5
P1F/OGBoFxZ78iDjk1Rd5jXLqJatbDxznqzWESNTM1Jc0TK544WqxQ+RsrrchQgE
bfbNweEXY4POjcNRLlfNE6QqGBHhDe/IQb2huKoOMbj5d3OTUOaNQLoBhWEI/0Yw
EkE4ncl9j580iWmAGGYqGMC0mx1eehfiU0gJ/w21RTJbXaNqS38twl3nlqwUo+tm
bDnYQdE4kK+5C3NPLg2xvk4ElbxOxl+sTF1xnemwnhf9g8O90HV8UNYN8R77GBi5
p/E4BGC3G8PxPEmvqZm+6047OX6QtQVsnESuaveO53n87p7sbuFkUClv0rCZh5Wf
Vgaz3oKToR2RkHYsytJAp/E9TJanjOQym2fkvnxQyPoknsmMqG/z9MIgpDISxTey
jLySg0uW5lRZ9X35HKKmMu21sFyO796oD/PkF/7PHmhJtFc2355+Ehdwfp2isJnK
j/jeUQBMm0WW0h2aWFoto/ljs6d5LsXF49Yii4iCqVz+5SOw3E8M1clUNFJ7HQas
sFVrPhTaHKJiiA42PCtYFV4hwj9Oknjz5eGr8MIcIclO2Xcjdbh8svbZmiIhio4b
mXmxrXFByXDNYGE/RI99
=zUBo
-----END PGP SIGNATURE-----

--Signature=_Tue__2_Oct_2012_11_51_17_+1000_kz5QJZ6tkGNGMWb.--
