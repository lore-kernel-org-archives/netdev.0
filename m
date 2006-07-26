From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Wed, 26 Jul 2006 10:10:41 -0700
Message-ID: <200607261010.48850.flamingice@sourmilk.net>
References: <200607242302.58670.flamingice@sourmilk.net> <200607260944.01692.flamingice@sourmilk.net> <20060726185333.36e13fdd@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4732818.iLxjrrJ38m";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:989 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1160997AbWGZRKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 13:10:45 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060726185333.36e13fdd@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4732818.iLxjrrJ38m
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 26 July 2006 09:53, Jiri Benc wrote:
> I just meant running some s/ {8}/\t/ on your patch :-)
>
> Also, I don't want to fix all of tab issues in d80211 by one big patch.
> I always have several patches pending (and other people probably too)
> and it leads to unnecessary rejects when applying them. Instead, I
> gradually correct them when changing corresponding lines.
>
Ah. Well, if you don't mind doing the space->tabs fix, please do. I don't k=
now=20
if I can get to that soon enough.

Thanks,
=2DMichael Wu

--nextPart4732818.iLxjrrJ38m
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEx6IYT3Oqt9AH4aERAn2PAJ45u1wZV7Oj24dMkl8iNrgQnMH/swCgztAY
9hOgi48h0HJEOJmRoWBAAq8=
=xwrL
-----END PGP SIGNATURE-----

--nextPart4732818.iLxjrrJ38m--
