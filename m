From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: report SIOCGIWAP event upon association
Date: Wed, 19 Apr 2006 08:02:43 +0200
Message-ID: <1145426563.26046.1.camel@localhost>
References: <20060419000231.04C3C87C093@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+HnDQo/5wtdmRM/prjvi"
Cc: netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:17570 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750748AbWDSGEd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 02:04:33 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060419000231.04C3C87C093@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+HnDQo/5wtdmRM/prjvi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-04-19 at 01:02 +0100, Daniel Drake wrote:
> wpa_supplicant requires some notification when association has completed,=
 and
> this is the way to do it.

Check out the patches I posted earlier:
http://softmac.sipsolutions.net/patches/

Specifically, this one by Dan Williams:
http://softmac.sipsolutions.net/patches/softmac-events.patch

I think that's what you're doing here, but can't do an in-depth check at
the moment.

johannes

--=-+HnDQo/5wtdmRM/prjvi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUAREXSgaVg1VMiehFYAQIrUxAAsC3YuvDjvQMYjsJfAkzVrwMcJFQYao1+
8gD4yABR3lRWrfFXGRKmhYvjw/adWkw2py063M2cEaOUIOW7+qZdOn0kFQxp/dnh
T8P2OAcazpnMZNm/7lm0uxzlP1o0WSD8SJrYbLigQLrjdLMvG5dQNg6GkHhWMi0v
0QG84KETgmG0R9Qxo+a/LJRz7S7zln7KG1mozm7jUppI1PjGezVj12QyfqG8bH8I
Jn8XcXELfmGCqs93G69uIdqweuMxFXZn7A1dqZLYn4oVNTADU4a9aiNPHrsRgGf7
UZ8kOeCHlHbZiKT6eUaMsow/zEFT0neNYZIPMhx1liPNbABKH32XqLEwZP0jGCjf
QfxYO34sv3ycVkvXUaASqLff8BlNFq4HYLfdfqGFRaJTNVXz+XPACvXc48xqG1Zn
0PT/aoGA975yTfj9B/EXN0pRjvGaR3yMfJ8fBj+/dOnztCDewk2jLTBEGAGLh5WM
taaa+n0Dh26R/RAB0jnf8+qbXLyVAlBkr1tGURhY5Uu4zz5OxpUQ38hbOTi3KEQu
Gl7XZUWYwSyVZTNLMQH0jhgNTWFqxjK4DHn20Z/58hboStdMjRFxZTVqtdZ93A+9
l+1cdlSxBp/La0NRpCRz8NfREUZmHZfM4nYXevTLX5YGjjrigkeDoEMMMx+MqVq7
kHnBi+XQJiA=
=hSUu
-----END PGP SIGNATURE-----

--=-+HnDQo/5wtdmRM/prjvi--

