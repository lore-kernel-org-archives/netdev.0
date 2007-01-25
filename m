From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought up
Date: Thu, 25 Jan 2007 11:51:27 -0500
Message-ID: <200701251151.32019.flamingice@sourmilk.net>
References: <1169707854.10593.41.camel@dv>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart9751093.RSQRZZxC4a";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:27751 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030352AbXAYQwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 11:52:00 -0500
In-Reply-To: <1169707854.10593.41.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart9751093.RSQRZZxC4a
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 25 January 2007 01:50, Pavel Roskin wrote:
> If the hardware drivers are supposed to do it, here's my patch.  It is
> working fine for me and ready to be applied.  The changelog is in the
> subject.
Let's fix this in the stack. This problem will be fixed for most users once=
=20
auto channel selection is implemented, and fixing it for users manually=20
setting the channel should be trivial.

=2DMichael Wu

--nextPart9751093.RSQRZZxC4a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFuOATT3Oqt9AH4aERArKFAKCebXzy1b8Ge9/rcJTHdZnst1cPtwCfbOcO
XvCehvaBOAnmBhIDSWzRhxY=
=Vc1g
-----END PGP SIGNATURE-----

--nextPart9751093.RSQRZZxC4a--
