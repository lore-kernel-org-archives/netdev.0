From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 4/7] d80211: add support for SIOCSIWNICKN SIOCGIWNICKN
Date: Tue, 29 Aug 2006 15:26:36 -0700
Message-ID: <200608291526.40874.flamingice@sourmilk.net>
References: <44F3572E.8020506@linux.intel.com> <20060829174531.GH1701@instant802.com> <20060829221553.GA31563@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart165273667.a9TedLazYZ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:5784 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751144AbWH2W1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:27:41 -0400
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20060829221553.GA31563@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart165273667.a9TedLazYZ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 29 August 2006 15:15, Ulrich Kunitz wrote:
> The softmac-broadcom and the zd1211 driver are using it to give some
> information about the driver bound to the interface. I found it
> quite useful to know which driver is bound to which WLAN
> interface. A readonly driver text info field would get my support.
Sounds like a job for sysfs.

-Michael Wu

--nextPart165273667.a9TedLazYZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE9L8gT3Oqt9AH4aERAlJDAKCQaIomh59sW3m3s8zpoEwstOu+mgCglC7K
666XzhzdpW89kECfCSTp8Yw=
=p9Gn
-----END PGP SIGNATURE-----

--nextPart165273667.a9TedLazYZ--
