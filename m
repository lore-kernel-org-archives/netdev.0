From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Porting ethernet over spi driver
Date: Tue, 22 Apr 2014 16:21:15 +0100
Message-ID: <1398180075.3624.191.camel@deadeye.wl.decadent.org.uk>
References: <5350ED9E.6080103@lategoodbye.de>
	 <1398133328.3624.186.camel@deadeye.wl.decadent.org.uk>
	 <53563E3C.3030108@i2se.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nlGGa+z1ApqyrV55eY9u"
Cc: Stefan Wahren <info@lategoodbye.de>, netdev@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53476 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932787AbaDVPVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 11:21:25 -0400
In-Reply-To: <53563E3C.3030108@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nlGGa+z1ApqyrV55eY9u
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-04-22 at 12:02 +0200, Stefan Wahren wrote:
> Am 22.04.2014 04:22, schrieb Ben Hutchings:
[..]
> > Most of the interesting new features are related to multiqueue and
> > protocol offloads that I wouldn't expect to exist in an SPI-attached
> > Ethernet controller. =20
>=20
> You are right.
>=20
> Btw, is simple power management (suspend, resume) a must-have feature?

If you're intending to get the driver in-tree, I don't think those are
an absolute requirement but I would certainly recommend implementing
them.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-nlGGa+z1ApqyrV55eY9u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1aI6+e/yOyVhhEJAQr+ShAA0FDJ1rvmuVnSK2VKep+DH1vit3i204yP
sigit7QltaOAqzy4K779Bgw+T7qEX/kLHQ6EYEBhyC7nTl3KSxj9k6C3PTj2yye8
iYFDmH8RX4TvOQwx9FKt0RUuuIUGqImol1aCsqH/Z5D5aILyBPxSpahRQaZNsCgw
4jJWsnZkt3US2V3hcfej0h9sGiq3XPFabs0IejrD/dI6ALXCiB5y8X7aaTUa4KoP
yJ0fxYoIV7821rxz9h7Uac17DFWP+TH092/xuxI5oNpCkvvAcJyU/a2TFOYjNhx2
yUpDEu6ldaN4v5HrNpZ/+B22PVojqNlyP2SycgFjkmMGg9jM6ZfCqR4M5Lmpr7kt
QoY0IfOpMpIuxUNlDdfW/YYF2K7rOtk10AXImIwh0wt/VSGWgEi8Lz608XDNwRPJ
kPaE/WW8e0lxHKkXE8UrzN89SFR/UAdyNvafJ10N98bR/iFyK7Rw7TBvXXiNaJw8
VML3X6cVjDJ6CkMJCmidse5Lrm+/cPxtq04wCijq4j+z6jhTxPWePle7UZTtVwAy
jUDpKs2Rct6d56uVse4/DvaGTcbahK1wIMI9yNaoLAwQvBclT8tGmyjX9pqRsTeH
esJLCM9kC54+cQcNmPkPNpQaXQI87DxF0czJyHpUPwGK8/mVPsx6pRKVVzHMBBXE
djL7iuhigtQ=
=932X
-----END PGP SIGNATURE-----

--=-nlGGa+z1ApqyrV55eY9u--
