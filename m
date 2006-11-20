From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 6/13] d80211: change the identifier netdev to
	ieee80211_hw
Date: Mon, 20 Nov 2006 23:45:40 +0100
Message-ID: <1164062740.8981.3.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964522.15473.52.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GeKNqcuJGpl+5lurPHYH"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57574 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966408AbWKTWrb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 17:47:31 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163964522.15473.52.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GeKNqcuJGpl+5lurPHYH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Mostly to remind myself to send a patch tomorrow...

I introduce ieee80211_hw->dev (struct device *) but don't actually use
it. Of course, I should use it in the proper places :)

johannes

--=-GeKNqcuJGpl+5lurPHYH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYjAU/ETPhpq3jKURAoiQAKCoLAM1ai7ZyiSWFYdSNi7oVL1sEgCeN73y
BFF2Rc3d76xc+szvC3WCt+U=
=MrvE
-----END PGP SIGNATURE-----

--=-GeKNqcuJGpl+5lurPHYH--

