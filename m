From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: d80211-drivers updated (zd1211rw-d80211 synced with zd1211rw)
Date: Mon, 4 Dec 2006 09:20:07 -0500
Message-ID: <200612040920.11583.flamingice@sourmilk.net>
References: <200612040250.43955.flamingice@sourmilk.net> <20061204125139.GA10912@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1729868.nipvjyfbPx";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:18742 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP id S936890AbWLDOUm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 09:20:42 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061204125139.GA10912@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1729868.nipvjyfbPx
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 04 December 2006 07:51, John W. Linville wrote:
> On Mon, Dec 04, 2006 at 02:50:39AM -0500, Michael Wu wrote:
> > Other (d80211) wireless drivers are welcome
> > to send patches this way if they do not have their own git tree for
> > Linville to pull.
>
> Please don't do this.  It adds to my pain for reviewing patches.
>
Sure.

> While I'm complaining :-), I would probably prefer it if you had
> adm8211 and p54 in separate git trees (or at least on separate
> branches) as well.  That way, if there is a problem in a p54 patch
> series, I can still pull adm8211 (or vice versa).
>
I will keep separate branches for each driver then.

> It is not my intent to scold (so please don't feel scolded).  It just
> is counter-productive to prematurely consolidate merging duties.
>
No problem. It seemed like a good idea for zd1211rw, so I was offering to d=
o=20
the same for other drivers.

Thanks,
=2DMichael Wu

--nextPart1729868.nipvjyfbPx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFdC6bT3Oqt9AH4aERAmNmAKCLoACB3Hex8hZMptbSLBgdntZBTwCeMm/1
WyDXH62MeA/nLCaTM5QHIRU=
=R8+U
-----END PGP SIGNATURE-----

--nextPart1729868.nipvjyfbPx--
