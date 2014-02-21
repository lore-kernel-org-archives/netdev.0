From: Justus Seifert <justus.seifert@dergleichrichter.de>
Subject: "ip route show" not in usage() for ip
Date: Fri, 21 Feb 2014 12:53:44 +0100
Message-ID: <53073E48.7060303@dergleichrichter.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="7a4jUQIK0cpisSBkWCKRCSCuvUOBHhW6X"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ngcobalt08.manitu.net ([217.11.48.108]:57131 "EHLO
	ngcobalt08.manitu.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbaBUMDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 07:03:41 -0500
Received: from [10.0.0.107] (g224193042.adsl.alicedsl.de [92.224.193.42])
	(Authenticated sender: jseifert)
	by ngcobalt08.manitu.net (Postfix) with ESMTPSA id 168B63A81C2
	for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 12:53:54 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7a4jUQIK0cpisSBkWCKRCSCuvUOBHhW6X
Content-Type: multipart/mixed;
 boundary="------------040807010505060303010401"

This is a multi-part message in MIME format.
--------------040807010505060303010401
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

hi,

i was looking at the synopsis of ip and noticed that the command "ip
route show" is not mentioned in the usage summary of ip.  is this
intended?  is this operand deprecated?

regards
justus

--------------040807010505060303010401
Content-Type: text/x-vcard; charset=utf-8;
 name="justus_seifert.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="justus_seifert.vcf"

begin:vcard
fn:Justus Seifert
n:Seifert;Justus
adr:;;;Dresden;Saxony;;Germany
email;internet:justus.seifert@dergleichrichter.de
tel;cell:+4915730640509
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------040807010505060303010401--

--7a4jUQIK0cpisSBkWCKRCSCuvUOBHhW6X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJTBz5PAAoJELFJh75Z+IvIQE4P/iv7gW1uj9a2/RjX+i6Aytus
S+cG4Q5TqNE0LgGuhQyzWwGMiFoqFuSwl9qZBV+VLmj2s2qsXJ0oRVNjvTyodenW
EE/OYwBIvm8F0xkywM4de9DSip0KkB1akC6zJjPeaIvDSlgEeBFuQb0IohwBp3T2
APnwSCpc5wUu2KI2NPpbNVcStoFEAb6dQkCZTw5hHftct3A0Zr9/sA68UXrOkX5a
vUCauXQi5tWlF3zjHbj9o4H+HpDoUF1ulG+aoPo9hsaqzdikuyLyNMDQkJAu0gh4
7s2wMtUmWafF1uUqchCTGm6JjERDn5CagOBGd3vBPYjCjad+hVXChesTZVKJen41
yMBj3G2WYfB+kLKSz3xRS3ciVVz/wZJnMrpTuNlenojQfATttBg996B2arxxDXb4
2pPvn0r611hqL7zXynjiFcd3+D82a3mqvEiSOlpuBi+vvBQUG3+S6oEnPDkUQBhT
SEBZrZlt+RpFgzEwiFxA6B/5abiavttPV3WCIlP2CXKUqwSVhqj8ECg86y7mCOhx
iFMw2I14RFP+dLNQo7FPQqWtaeJvo654WkiqusPo1vRTtErvxhI8z5x3kSA6MZk0
FFS/IwtLJnENKSXMUnD7SGn3lzk3aRcO9LUE/eL7aIWQTD33ldSkFn3bG+AujcPj
GKR4HJKZwWZOQrzTPHqT
=oOnK
-----END PGP SIGNATURE-----

--7a4jUQIK0cpisSBkWCKRCSCuvUOBHhW6X--
