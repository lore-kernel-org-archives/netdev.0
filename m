From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless-dev updated -- 23 November 2006
Date: Fri, 24 Nov 2006 00:49:53 +0100
Message-ID: <1164325793.29229.3.camel@johannes.berg>
References: <20061122174734.781c18d1@griffin.suse.cz>
	 <20061123163308.GA8287@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Jt164bIekIf75pxlzSji"
Cc: Jiri Benc <jbenc@suse.cz>, NetDev <netdev@vger.kernel.org>,
	flamingice@sourmilk.net, ivdoorn@gmail.com, mb@bu3sch.de,
	hong.liu@intel.com, mabbas@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42655 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1757505AbWKWXvt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 18:51:49 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061123163308.GA8287@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Jt164bIekIf75pxlzSji
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-11-23 at 11:33 -0500, John W. Linville wrote:

> > I won't attach the patches this time as some of them are quite big and =
all
> > of them went to netdev a few days ago. Please note that these patches b=
reak
> > all d80211 drivers.
>=20
> Driver authors, please observe the warning above.

You might want to not fix it for now and wait until we've discussed the
[RFC] patch series about cfg80211 more because that removes
ieee80211_hw->index again to use ieee80211_hw->wiphy->name.

Sorry about that.

johannes

--=-Jt164bIekIf75pxlzSji
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFZjOh/ETPhpq3jKURApyuAKCcn3yyDcDrOcfYhWv7wVQLnVQ2UACgrzkw
3ZcbKEOt34kUx2kfNPwmMs8=
=hC+y
-----END PGP SIGNATURE-----

--=-Jt164bIekIf75pxlzSji--

