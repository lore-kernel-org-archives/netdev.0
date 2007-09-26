From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: net-2.6.24 rebased...
Date: Wed, 26 Sep 2007 09:19:47 +0200
Message-ID: <1190791187.18521.340.camel@johannes.berg>
References: <20070925.233344.43202361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-03MHGrKzY9+kr0PdT21A"
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, jeff@garzik.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57398 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbXIZHSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 03:18:37 -0400
In-Reply-To: <20070925.233344.43202361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-03MHGrKzY9+kr0PdT21A
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-09-25 at 23:33 -0700, David Miller wrote:

> 	http://vger.kernel.org/~davem/0433-Z1211-Fix-TX-status-reports.patch
>=20
> What probably needs to happen is some other changes that
> were in z1211 need to go into the non-mac80211 driver and
> then this patch applies correctly.
>=20
> I tried the simple thing to rename the directory in the patch
> and that didn't work, obviously :-)

That patch is specific to the mac80211 version and you don't have that
yet, it just needs to be stick along with it till the next time.

johannes

--=-03MHGrKzY9+kr0PdT21A
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG+ggT/ETPhpq3jKURAsRZAJ9JFlNCSHOHCfgVAjloMzhk9WdgMQCfeP36
RIAFKo6tzchOSUQmP67TgEc=
=lESa
-----END PGP SIGNATURE-----

--=-03MHGrKzY9+kr0PdT21A--

