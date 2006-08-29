From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Tue, 29 Aug 2006 15:50:25 -0700
Message-ID: <200608291550.30203.flamingice@sourmilk.net>
References: <44F356DF.9000000@linux.intel.com> <20060829175544.GI1701@instant802.com> <44F4BF9E.4040309@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1318259.pIOzkCfxhN";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:1951 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1030201AbWH2Wur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:50:47 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
In-Reply-To: <44F4BF9E.4040309@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1318259.pIOzkCfxhN
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 29 August 2006 15:28, Mohamed Abbas wrote:
>  SIOCGIWAP will always report the bssid no
> matter what the status of our link.
That is not the case at the moment. Were you planning to change that?

-Michael Wu

--nextPart1318259.pIOzkCfxhN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE9MS2T3Oqt9AH4aERAoBLAJ9dRAml+ObAOxZadnMvjr9UIzaZSgCgrwv8
4+RasRjo/fRJJDJ4tr0e1IU=
=CPIP
-----END PGP SIGNATURE-----

--nextPart1318259.pIOzkCfxhN--
