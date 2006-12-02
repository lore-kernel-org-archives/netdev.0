From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: zd1211 ported to Devicescape stack
Date: Sat, 2 Dec 2006 13:32:28 -0500
Message-ID: <200612021332.33255.flamingice@sourmilk.net>
References: <200612020316.50965.flamingice@sourmilk.net> <4571A295.4030700@gentoo.org> <20061202175737.GA5577@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1172178.dgixvXJjjm";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Luis Rodriguez <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:34953 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1424318AbWLBScs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 13:32:48 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061202175737.GA5577@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1172178.dgixvXJjjm
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 02 December 2006 12:57, Ulrich Kunitz wrote:
> I intend to track the d80211 stack, care for the forward porting
> and see also a number of things, which should be done for d80211.
>
> - 802.11a support
> - better d80211 integration (d80211_tx_status, led stuff)
> - cleanups
>
Great! I expected to handle the patch porting alone, but it's better to hav=
e=20
someone used to this hardware doing this.

> This will make the d80211 driver the development branch and the
> mainline driver the maintenance branch. As already stated I intend
> care for forwardportsi of the mainline fixes, but IMHO we should
> not care to much for backports and backport compatibility.
I avoided cleanups in the patch to make any patch porting from the mainline=
=20
driver easier, but if it's okay with you, I might make a few zd1211-d80211=
=20
specific clean up patches.

Thanks,
=2DMichael Wu

--nextPart1172178.dgixvXJjjm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFccbBT3Oqt9AH4aERArgdAKDMuhdVWicAsCk5mf7r8mpV0QfRngCeIaSg
LYF89QRJAex2Gzkqg/71tL0=
=n07X
-----END PGP SIGNATURE-----

--nextPart1172178.dgixvXJjjm--
