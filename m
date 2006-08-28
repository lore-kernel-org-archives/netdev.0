From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Mon, 28 Aug 2006 14:17:34 -0700
Message-ID: <200608281417.39948.flamingice@sourmilk.net>
References: <44F356DF.9000000@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2054624.IPlkY8fIxb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:44248 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751472AbWH1VRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 17:17:53 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <44F356DF.9000000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2054624.IPlkY8fIxb
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

It would be helpful if you inlined your patches instead of attaching them n=
ext=20
time.

I'm not comfortable with using the name for this purpose. Don't we just rep=
ort=20
00:00:00:00:00:00 when not associated? Also, for radio off, wasn't that bei=
ng=20
covered by the rfkill patches?

=2DMichael Wu

--nextPart2054624.IPlkY8fIxb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD4DBQBE811zT3Oqt9AH4aERAvZMAJjCtMkHP5ZDPRet5acA5Q+Izf00AJ9qworg
+xSKeXDpJT3mwfJZZD6gxQ==
=cLpb
-----END PGP SIGNATURE-----

--nextPart2054624.IPlkY8fIxb--
