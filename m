From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] d80211: Make MACSTR/MAC2STR macro available to drivers
Date: Mon, 24 Jul 2006 09:40:13 -0700
Message-ID: <200607240940.19670.flamingice@sourmilk.net>
References: <200607230143.31375.flamingice@sourmilk.net> <20060724155435.6ec32485@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2188827.nZ3Ue9zQ03";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:13261 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932207AbWGXQk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 12:40:27 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060724155435.6ec32485@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2188827.nZ3Ue9zQ03
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 24 July 2006 06:54, Jiri Benc wrote:
> I really dislike those MACSTR/MAC2STR names. I always fail to remember
> which one is which. What about renaming them when we are touching them?
>
> And why not to use MAC_FMT/MAC_ARG names as used in net/ieee80211.h? ;-)
>
I dislike MACSTR/MAC2STR too, but I was trying to minimize changes to the=20
d80211 code. I'll switch to MAC_FMT/MAC_ARG.

=2DMichael Wu

--nextPart2188827.nZ3Ue9zQ03
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExPfzT3Oqt9AH4aERAvrSAJ9nHWkzUrtFSlIJU2N0GHzv+hlrdACgnWr+
tDhvoDkXy+K0TAr3TL8UECg=
=Kpnm
-----END PGP SIGNATURE-----

--nextPart2188827.nZ3Ue9zQ03--
