From: Johannes Berg <johannes@sipsolutions.net>
Subject: HCI crash after tearing down ppp connection
Date: Tue, 27 Jan 2009 20:01:21 +0100
Message-ID: <1233082881.4455.14.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-N4tNqJu3+dzck88YidBU"
Cc: netdev <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47909 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbZA0TBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 14:01:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-N4tNqJu3+dzck88YidBU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I use /dev/rfcomm0 to connect to my cell phone, and then to the internet
with ppp. Occasionally (two out of the three times I used it today)
after I poff the connection the machine locks up. The second time I got
a log, but because my display resolution is bad it mostly scrolled off,
so I only got to see that hci was involved somehow :/

Anyone aware of any such issue? This is on
2.6.29-rc2-wl-11979-gc32422d-dirty (-rc2 + wireless bits).

johannes

--=-N4tNqJu3+dzck88YidBU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJf1n+AAoJEKVg1VMiehFYoOsP/3F7jhNlaVvQOIn7U5gnHYgl
EbzvG3PX2jYYkYzmZ5ZB3RCIQZxFMNvNDVCDALK3VX89AbD5SgGHVNSW3UWy1ltu
T8Alx4QtlkbJ2RcPKoAuj354KnOAW4W5d1+zQba9sQL+VSCTSvb5IEXxodtsDB8k
rfH4ZRiK2zifMTj1d79MnZ2rxHlm61fD67atSt1/G3htz+rfIkb4DbOI1/UzPLf3
Aa5Aa8j4OTpg5K3yBhoAb6kBJsSm/SpxsZMooCepgxFliyOuZ8wsqkHD+wNQcV0G
adxUnkrZLu121Lu5uuFWBUa27JU8cc0VlpNjAvwQrywcG9+pQd782SNRZ7pmYo44
MwcQeVRWihK2WBd+iCHj/FF336Dp0wpFnRY0xax688rXB+vmPb/vT23Z3DR+RSj0
8NVOxWsI4Rc2I/ZTN2RDD2xdVtC3vVNB+si5Fbu6/BJfyCBODFpwousy0XJgwae4
54v9oL0PCrO4B3GowNMg5s1YjK12s5xogbEZN0QHmV7amuPvqWq+4RCl+LQ/SQvo
GQRPNpgkxD1KMciCH125xmcsz/zWxEebUnGDQz3LmRXzkaKP9bNwySmUdBZoqlZT
9+7gYtFBps7TyO/jDlkXvT57YzxJc+xPJRyh6qi2rjWCmikqKpoJD2bTmXrmX2Ci
Lu3TM0kRholgh9ETS3MO
=a3Ln
-----END PGP SIGNATURE-----

--=-N4tNqJu3+dzck88YidBU--

