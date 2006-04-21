From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 23:05:49 +0200
Message-ID: <1145653549.3897.51.camel@localhost>
References: <20060421201147.D4F76482CF@silver.suse.cz>
	 <1145651369.3897.33.camel@localhost>
	 <20060421224935.5acd79bf@griffin.suse.cz>
	 <1145652778.3897.43.camel@localhost>
	 <20060421225729.34dae18b@griffin.suse.cz>
	 <1145653288.3897.49.camel@localhost>
	 <20060421230500.1fd6be92@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-nxIJWDV5BJX/KJLIAOXq"
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:62873 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964776AbWDUVFw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 17:05:52 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060421230500.1fd6be92@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nxIJWDV5BJX/KJLIAOXq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-04-21 at 23:05 +0200, Jiri Benc wrote:

> Not necessary. It was just an example of the worst case. In typical
> case, you will receive something more - probably all data and management
> frames but no control frames.

Ah right, yeah makes sense then I guess. So monitor is a way of telling
the driver "give me everything that you can" :)

johannes

--=-nxIJWDV5BJX/KJLIAOXq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARElJK6Vg1VMiehFYAQKWug/8D387TKNdZgdqitS+zljQVBlsu8mF+tYD
XXz10McgeL6zFJAtQ1KqfAAxeZ/E3/DOBs9R5d0WenJUE1a2wc5V4IC3AqMPDrsO
yKDeFObxtw+ScgDXm8cCOWk+mhEZWtpHQ738S2Vol+m7XV5pbbtKfkfmmn/E1nkb
VJLV2FdfNeKhiX2KIHcQSd+BT+gYykt3QAdnEDZ97FNbJARU/mca4HLa+RZY10mf
x3i62Yx3G0WYZ1H7sn/Ry7zc5w8cICTmYr/ihs3Qzg8tDYU3K+vX3sReigdtLPlh
TzMP04n0MZrgQe1oCMnJUJURoqU9g6R79nJTzOOLWYhVM04Q5UORqYTrzcwEnsMP
f185wxTEpZn8heuiSFbgMCdQXNkk5m9PShXGVLPOe9At+LCt2ium9+pGZ6tN3+LL
LvWA/dRWzwL27K6dNgOeiHOEQZwozwTgm4QYguWXueY34F/Y1OfwDTlxNNF7VoQz
3pUUa7Z++pE8UlOS9nk1nbtk5hfTfUJZNjDxZMm+nqru61b1SqA6G5ErZktoyLo8
8Ny9YLl35CZ4Fm/wg7X6U38aHY32MrLsWqyMwYVO0howTBoUwteQ3VezBUAVqbz9
hNBPrmb0ZlNNGfzEjW1iaRh6jJcEb8Xh97OOPnk5ZvHoP5g/EvA41JJrCSQ/5q/n
/5xEDitvWBg=
=Mwla
-----END PGP SIGNATURE-----

--=-nxIJWDV5BJX/KJLIAOXq--

