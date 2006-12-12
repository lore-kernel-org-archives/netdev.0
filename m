From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 0/3] Fix breakage in d80211
Date: Tue, 12 Dec 2006 12:48:45 -0500
Message-ID: <200612121248.55141.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4782037.ANvof2tdzG";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:20497 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932305AbWLLR4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 12:56:42 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4782037.ANvof2tdzG
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I've made some patches to make d80211 compile with recent changes in Linus'=
=20
tree. They've only been compile tested since I haven't bothered to fix merg=
e=20
conflicts (or rather, haven't figured out how to) and make everything=20
compile, but I don't see much of a reason why it shouldn't work. Hope you=20
find this useful.

=2DMichael Wu

--nextPart4782037.ANvof2tdzG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfuuHT3Oqt9AH4aERAqymAKCJ4SmNr0GHq7LVEd+NaapDKDGveACeJTc3
ftM2+iLPtLyAzqLHYIWzgUs=
=H/rE
-----END PGP SIGNATURE-----

--nextPart4782037.ANvof2tdzG--
