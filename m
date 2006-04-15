From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Sat, 15 Apr 2006 21:24:16 +0200
Message-ID: <1145129056.6560.0.camel@localhost>
References: <20060411085805.949313000@sipsolutions.net>
	 <20060411085841.252064000@sipsolutions.net>
	 <20060413020010.2ab16d7b.zaitcev@redhat.com>
	 <1144919176.4187.44.camel@localhost> <1144920890.4187.50.camel@localhost>
	 <1144930441.2372.12.camel@localhost.localdomain>
	 <20060413161359.GA21074@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oLcgeSw6OMQ5plw1eHlY"
Cc: Dan Williams <dcbw@redhat.com>, Pete Zaitcev <zaitcev@redhat.com>,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:5767 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751268AbWDOTY1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 15:24:27 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060413161359.GA21074@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oLcgeSw6OMQ5plw1eHlY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-04-13 at 09:13 -0700, Jean Tourrilhes wrote:

> 	Yes, Dan is 100% correct.

Right, slightly later I posted a patch to do it that way. After everyone
else has discussed, do we agree to leave the patches as they are now?

johannes

--=-oLcgeSw6OMQ5plw1eHlY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUAREFIX6Vg1VMiehFYAQJhAQ//QidCBVfRFUsgNFKh+0d9vrjmAdvfTN7D
GKdrqYsBmC3J9wH7q7QIonOMqeRH+0RtW0EeoIUwMoP0GnuFiiWTm/+jPCZ8eoNw
A5KB1v4ZoMrj1qu+OM/VdUhTkJGLo3u42OyVGsnfvMFBRvm0+bkIP40wDT2ZHKwx
LJ+yVeMn+Np5xMblJWB5ynFEcIgUBRbs+MGZUs7bfb3OKRSnVldcSqpmcGHBUmYM
llt9xULW97bNugGsPfBZLJpBc09wSeTbOywzepbvdo9+Wu4K+Bz4n8zeGetbdE4Z
wttdJQkwj4KESJ9v9Tm00crBBVYOSbCjvebXJdFfR3sV2Ac7UQTx/aaAaaL0kDBE
YuLIY5mkBipxRn+fMkKTZcjxsq0lLLd4E+ZKukg5X97FOqU9M+EoDG/FNqmGqgIx
bv0Ux1HXfbHU8U/4kpwGrAjx/MsG1pRA20lm/YLE/GbKFhP+DMo6g5NiiRlgSecj
oZlWdwfgwoTXlg4gwcuKwo4DLet6VIIS3TJGafBal83JwcQVN5RgUJi8dffLhDYk
PMEr/tSFJ188judTcsyQYuPlH4qWMznu1SbZxzjRXn/o5+jcEqz2myYmaQ1N3PQC
lnHeJDcMKbjZ8BjQBy3wyumqFQPchnkGJUIk/CWPHWLD2d7Qdo9u305XBbyLvMKy
T7JfQUYTBe4=
=AL6/
-----END PGP SIGNATURE-----

--=-oLcgeSw6OMQ5plw1eHlY--

