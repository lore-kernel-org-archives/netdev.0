From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] econet: Move to staging; remove from defconfig
Date: Sun, 28 Nov 2010 01:53:35 +0000
Message-ID: <1290909215.3292.230.camel@localhost>
References: <1290897868.3292.59.camel@localhost>
	 <20101128002135.GA4562@suse.de>
	 <20101127.172644.226781076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-SgV4sR0a/6FSMteAxO9e"
Cc: gregkh@suse.de, netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-arm-kernel@lists.infradead.org,
	debian-kernel@lists.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48214 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750830Ab0K1Byj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 20:54:39 -0500
In-Reply-To: <20101127.172644.226781076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SgV4sR0a/6FSMteAxO9e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-11-27 at 17:26 -0800, David Miller wrote:
> From: Greg KH <gregkh@suse.de>
> Date: Sat, 27 Nov 2010 16:21:35 -0800
>=20
> > And I need an ack from the networking maintainer to be able to accept
> > this also.
>=20
> I'm not applying this, nor do I want anyone else to.
>=20
> If people think this protocol is not maintained adequately
> right now, wait until you push it into staging.
>=20
> Furthermore, once Phil Blundell was made aware of security
> holes in econet he fixed them within a few days.  Which is
> much better than I can say for some of the other protocols
> and filesystems in the tree.

Those bugs were present for years and would have been obvious to anyone
who cared to read the code.  While I very much appreciate Phil's quick
response, I don't think this reactive maintenance is enough.

> Moving this into staging, is therefore not appropriate.

Oh well, it's not enough as if many distributions bothered to build it
anyway, and we've learned our lesson now.  Whether it's labelled as
staging or not, it's dead, Jim.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-SgV4sR0a/6FSMteAxO9e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATPG2Fee/yOyVhhEJAQIQHRAApbD2zGr0+5Nyq4NAZuchU98lEdwn1F79
YlCNfV2BuhE+sezGqGWtJhn8UaLMjpei79XkjAkrM8iHQQE32RS1WAUgIFCvHRz8
bHdE4pckr0X7BlW8sQL+3EWUvG56cmE0ZdfoCWn9NoLIOHCzCqWfiIk3p4y6ADKO
H1m0RvxP2xdiocY1TzLG2J0Jbe9Ba9WHy7WB0VaR9wsjt5ju4XphsdfB4QrTZUHj
Pk2NCM/gUBHB3tAA7TFFzioqDDbBvsAl2ZsxMzHwISmouo+ltqFn1qCN72JfXDe1
Z4B5EoMiTW3RUEEnFkiYCgTyjj2iqn+Zs+WyV7zS+DOnjL2Z45M+ItPhTQQNjwfu
EEX+8BJ6JU1LK0rUouonukJoN8bm6yfK2AHAo7CrveoCZHZZAgPWXODI3Rb0VNKi
dfwULbU5tQNbgt2ED9XEYXwyRwaSl+bWiGpg8tNKSpe6OK7cq+ElZftuG82JKGPk
J4xPXIWiFXF1kHVhucPNiH51mkJJa4MCokWzy/eInT/5im07WfolKROapgorGOpW
LpHMXxybCLO0QpZ6udAZ6YjO76Fc7p3veOtrO5qT0duOgO2D/t4/Sa3O7ic7rySb
C0ntri/Sjb+gm1KgnRuxaLAGaITDUGncz/FbhHy7YIltIwq4kXy4IVgUFTYzgmFI
6/iNxO6oWjo=
=jomz
-----END PGP SIGNATURE-----

--=-SgV4sR0a/6FSMteAxO9e--
