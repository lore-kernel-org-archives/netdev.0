From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: dscape doesn't auto associate
Date: Tue, 23 Jan 2007 21:55:48 -0500
Message-ID: <200701232155.52509.flamingice@sourmilk.net>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com> <200701231843.05902.flamingice@sourmilk.net> <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart11469811.u0aMzdKppk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Jon Smirl" <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:39908 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965623AbXAXC4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 21:56:21 -0500
In-Reply-To: <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart11469811.u0aMzdKppk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 23 January 2007 20:48, Jon Smirl wrote:
> As for running as an AP:
> rt2570 will start in Master mode
> zd1211 refused to set Master mode
>
No master mode support in zd1211 yet - I haven't had time (and the other tw=
o=20
developers don't work on the d80211 version yet). Only client mode is=20
currently supported.

=2DMichael Wu

--nextPart11469811.u0aMzdKppk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFtsq4T3Oqt9AH4aERAq8fAJ4yOYVWn/F4L/RjFAe2nCeUiDsQdgCeIk5u
9/r+Fxa8c1J+vLHLWLrmhOU=
=fIZu
-----END PGP SIGNATURE-----

--nextPart11469811.u0aMzdKppk--
