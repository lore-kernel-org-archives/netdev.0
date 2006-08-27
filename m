From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: lockdep rt2500usb report
Date: Sun, 27 Aug 2006 01:10:45 -0700
Message-ID: <200608270110.51244.flamingice@sourmilk.net>
References: <44DC4110.6080300@sipsolutions.net> <200608262214.26827.flamingice@sourmilk.net> <200608270917.16363.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1769877.qrcFQoxrYM";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:46528 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751680AbWH0IK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 04:10:59 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200608270917.16363.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1769877.qrcFQoxrYM
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 27 August 2006 00:17, Ivo van Doorn wrote:
> But in the end this is something that should be fixed in the stack right?
> rt2x00 indeed seems to miss the ieee80211_netif_oper() commands,
> I'll add them immediately.
>
I'm pretty sure it's entirely in the stack, and you shouldn't need to do=20
anything to your driver.

=2DMichael Wu

--nextPart1769877.qrcFQoxrYM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE8VOKT3Oqt9AH4aERAlMFAKDIR6qgt6J6H8LVkh4vGK05ZRtjwQCffeWC
3wQsnX2JuE3fqfsvojwhS1Q=
=QmPI
-----END PGP SIGNATURE-----

--nextPart1769877.qrcFQoxrYM--
