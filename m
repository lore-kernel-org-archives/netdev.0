From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Wireless fails to associate at boot (regression) due to commit
  77fdaa12c
Date: Tue, 21 Jul 2009 12:49:26 +0200
Message-ID: <1248173366.11316.0.camel@johannes.local>
References: <392fb48f0907202254t120ff3cmec885d164dc3344d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-xEwIPU0kOf+swPZ4PrEw"
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40274 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440AbZGUKt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 06:49:58 -0400
In-Reply-To: <392fb48f0907202254t120ff3cmec885d164dc3344d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xEwIPU0kOf+swPZ4PrEw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-07-21 at 14:54 +0900, Mike McCormack wrote:
> Hi Johannes,
>=20
> The following commit causes my wireless network not to associate after
> bootup.

Hard to believe, but you're using wireless-testing which is known to be
broken anyway at this point, because John has been on the road and
hasn't merged fixes...

Also wrong mailing list. If you follow wireless-testing, really do use
(and read maybe) the wireless list.

johannes

--=-xEwIPU0kOf+swPZ4PrEw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKZZ0zAAoJEODzc/N7+QmavhwP/jifyNaLvFexRvse2NrfwGEF
kPmuTI0eK4+M5GDA/cya94bOx/Xp3ccgOAJzW0WU3Vh0Jfsuiu6SxnFLOiD5RIl1
P2bEUClfa6fKblkVcaihJTzBjyfyFYOXhdKoZg2zfgFOU2a79iWLV0E6gwn0Skk+
WnHau+wZDQOo56hKprKzfnRfHd2qb8bQ4vsGRCEccO4Pxd5tKnxQtbgd6JjlmW7Z
ZqJkDN1QpoyUxOwCklcODXk9ldnn0qLKw6IQDaUg+oEz/7AXhPA/fe9uYyETze/l
o0HXRvQSvhNTjti3rKm3HDNknjPVlD+M6DystOi9j5gK1B06PaefHqLyLYQKeYyg
USdHK/ASXeku29Orbj1awregOQHFkevBkmwQlMTEEAqP8bItuRpnbj+PJ0ysMFai
lEN+89HWmcZjcWI1WYh2PdtyDwkW/j2n55vbLXYjEI06/AsSzfxb8RhWs3/cLUy6
KHjU6eGC7Lb3kgaskgm+d5rAsC9MqjxA0ko4x3ZwFRFuXP9d9TspYeZ9SPVChkPQ
CxU8Q+5iTJkqo+E2J6qMbszOF1o/mps1HRDpawHwKPEG9X+0ZAZP7mHOwx7OHM+D
QfhSK8ppIGRWo8oX7UWEhNsm96MKG0eKWkr4ORpycyXjXMYRta09/Oqx3Io/3QFP
vcRtFLIRIK/Y/DeF3olZ
=Hxzl
-----END PGP SIGNATURE-----

--=-xEwIPU0kOf+swPZ4PrEw--

