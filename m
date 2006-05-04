From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bcm43xx-d80211: measure the channel change time
Date: Thu, 04 May 2006 14:36:56 +0200
Message-ID: <1146746216.1137.33.camel@localhost>
References: <200605032105.53694.mb@bu3sch.de>
	 <20060504111140.050c3e2f@griffin.suse.cz>
	 <1146745340.1137.26.camel@localhost>
	 <20060504143355.7bbfef35@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-SoIqbvbudEWK0lsbMql0"
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:21213 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932287AbWEDMhK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 08:37:10 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060504143355.7bbfef35@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-SoIqbvbudEWK0lsbMql0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-05-04 at 14:33 +0200, Jiri Benc wrote:

> TSF is set to a value sent by an AP. Is there anything that prevents
> that AP to send you e.g. 0xfffffffffffff0?

Ah, good point, I didn't think of stupid APs. Yeah, it should handle it
I guess.

johannes

--=-SoIqbvbudEWK0lsbMql0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARFn1ZqVg1VMiehFYAQJKVg//fq4Uq00U856nUmcaPM8tG1WFZ3BXqYil
gZUwO2vMovBEUQajv3KxvSjQ0J3Ce3gHd3sBOiQKHh5RglCeX4vbnbeuZoHwetq9
wSZuSmkaxPbjjYDZFN8Znde/5WzRqDBtDd63x5ZtYMtHG8/ive2nOX16hbUiJo+F
/cJEB6CqcKKQfoducYIXHqAhVEmlCUSeSkuvz3e1hm3+QQocGgyp3NAp49C2Lt7F
gBNOjvjQSO88oyqenrOwqjkj1kDMCW2U4kwpeb7/1jGGdVAhJMNRMRoDgbI3hDhN
DR8B6eIV0mDtBZ0RDLLNE0rB1VckXzHEB7r55HV49HK1iIP3EnmrdvTShdUD+gcR
qjNMlaGaV2cez+WHEzX/JytvnjVeNEUn8NwUMNX/0pVPIldItcbwTEf0L/dXPW07
Hs9PdbWqomqd8G8H8aKfx3BqPYnIQtWazLS8x+5BH1+Fsl+h6UxPWfiEuSkYoJVD
cZ4wRadZJJsvvXw5mGKCl67HkklVCr2/XlpVUBSk9NVUlaho0BtYqztwO3mQoOq2
SLZ53dLX5dQwL/juQUGtWv8anI62+DbPj9CgUJjTbzNoTLUwHa9YpAdVRj4jRrKc
mdBkY/b8rNz1XGjQFZAdsW17uhLPb54s1ZdPccpC3A0XSCuVDHSop+qjaTyrBgE/
y4KEuaRyuhE=
=GbJV
-----END PGP SIGNATURE-----

--=-SoIqbvbudEWK0lsbMql0--

