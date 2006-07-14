From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: michael_mic in crypto api?
Date: Fri, 14 Jul 2006 00:23:41 -0700
Message-ID: <200607140023.48727.flamingice@sourmilk.net>
References: <200607132350.25755.michael.wu@mozilla.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3094915.sMjYlEAByY";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:60546 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S964797AbWGNHYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 03:24:03 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <200607132350.25755.michael.wu@mozilla.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3094915.sMjYlEAByY
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 13 July 2006 23:50, Michael Wu wrote:
> Is there really a point to having michael_mic in crypto api? The only users
> are 802.11 stacks. I can imagine arc4 being used for other purposes, but
> michael_mic is very much wireless only. The only advantage of keeping
> michael_mic in crypto seems to be the testing code.
>
> -Michael Wu
Err, sent from the wrong address. Opps. Too many email addresses..

-Michael Wu

--nextPart3094915.sMjYlEAByY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEt0aET3Oqt9AH4aERAg90AJwNae+8Ah41V76PpNm++RcroPE1uACfaxqU
ogorV0bU149NWeDP+ZjBK1c=
=dO2d
-----END PGP SIGNATURE-----

--nextPart3094915.sMjYlEAByY--
