From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: d80211 constants inside d80211_common.h
Date: Wed, 27 Dec 2006 11:07:38 -0500
Message-ID: <200612271107.45572.flamingice@sourmilk.net>
References: <40f31dec0612270032g284160a8q2c6f190b4296a455@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5868658.34m3AdINCr";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"David Kimdon" <david.kimdon@devicescape.com>,
	linville@tuxdriver.com, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:40203 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932978AbWL0QIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 11:08:18 -0500
To: "Nick Kossifidis" <mickflemm@gmail.com>
In-Reply-To: <40f31dec0612270032g284160a8q2c6f190b4296a455@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5868658.34m3AdINCr
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 27 December 2006 03:32, Nick Kossifidis wrote:
> I did a grep inside drivers/net/wireless/d80211/* and they are not
> used yet in drivers. Can you plz fix it before drivers start using
> them ?
Already fixed, just waiting for wireless-dev to get it.

http://kernel.org/git/?p=linux/kernel/git/jbenc/dscape.git;a=commitdiff;h=4ae94181f808da96352478c6d4102e3b0b5dfaac

-Michael Wu

--nextPart5868658.34m3AdINCr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFkppRT3Oqt9AH4aERAr/HAJ42+3Wbzdh8wuvaZkkxglmvAA7g6QCfe3B4
aUpak2+XvnabaDaOyKjHft0=
=AZOf
-----END PGP SIGNATURE-----

--nextPart5868658.34m3AdINCr--
