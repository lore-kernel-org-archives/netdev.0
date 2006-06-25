From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Streamline testing of 802.11 drivers
Date: Sun, 25 Jun 2006 14:42:21 +0200
Message-ID: <1151239341.7608.63.camel@localhost>
References: <43e72e890606231333kd0fc534x5d08dad955d13bf5@mail.gmail.com>
	 <449C6FA5.4060300@lwfinger.net>
	 <43e72e890606231556o57f1590fve91a98b5adfa5379@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CPBrJGf3NlxgxXSxmbH/"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:24790 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751238AbWFYMmi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 08:42:38 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890606231556o57f1590fve91a98b5adfa5379@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CPBrJGf3NlxgxXSxmbH/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-06-23 at 18:56 -0400, Luis R. Rodriguez wrote:

> Thanks Larry -- I'm sorry for not mentioning in the original thread
> but basically miniPCI and USB is what we can slap onto our nodes so
> far. We'll have to figure something out for Cardbus..  I searched and
> it seems there some miniPCI bcm4306. I'll see if we can come up with a
> cardbus solution though as I'm sure there's gotta be some card which
> don't ship in other form factors. Will get back to you on that.

I'd say most cards come at least in USB or miniPCI as they are/were
mostly for use in laptops. bcm43xx certainly does, we still have some
funds that were donated so we could probably fund a few bcm43xx cards
for the testbed.

johannes

--=-CPBrJGf3NlxgxXSxmbH/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARJ6Eq6Vg1VMiehFYAQIvmRAAo/EYoby2ux1ixt1+Vq2/oLPE5nI+asUc
spFzpBnKCputaZexBoXbGMQAhIsVUSTQSBH3wLUNesFd1nGNN057iB7DmNIQ3so7
lFwTcUeeEDL5+TFW6vQ53+TC1/ey7etkmVGvfOx9HApbjuKE78ws56V5gPohG6Jp
v43WT5DDe3GfYJ5xYmriy3SFj3fAYg40m1KcezrRFG2Xr0+j7nMxD7eao44OaDlv
Y4zVetvyBCZh5VLy6inV2ZNFC+8U/m706TxcYo+s94BEdx5iwGakt4sBW0WJMlsd
pEDi6njm9+fMOrGG3WPEEIUebASI1QZJFlX2lN2PJrpqP8AsNDO00WMUDwZfKfO0
hfT2UNClL0PZJ7dKap/khMw0vbddDEibA9tK4+6385GStpsRyIY8KXYd+reJaqJi
HX+3+zRetcL47OY2pHEUCk9rdd4KHdO7zrJ+/WVOsT9GnpqjhXzjV+v1Z6T9kY9P
uiJk6rnPxEKWOHBwr/aZquNbq02hpk/qMCF3QiTgBMgpJM6/ynV9i/oNa9LUgoqh
R0pdpilbjk7++5elHDhWLEMKYRhEFLZgYcMFhpo/tFVgdUab2bcmFRMcZryKnKAr
WEqbjiGODd+mf4gQ3YJvgmi9mjGtld+CoSL3FReoZiBIGzrCzV0MrpqEH1Bs9v4C
6+uKmNow3as=
=Y2S2
-----END PGP SIGNATURE-----

--=-CPBrJGf3NlxgxXSxmbH/--

