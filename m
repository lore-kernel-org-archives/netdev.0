From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [3.0.y, 3.2.y, 3.4.y] Re: [PATCH 2/2] [sky2] Fix for interrupt
 handler
Date: Wed, 14 Nov 2012 05:49:00 +0000
Message-ID: <1352872140.4867.16.camel@deadeye.wl.decadent.org.uk>
References: <1341394726.14972.41.camel@mlindner-lin.skd.de>
	 <20121025223646.GA1131@elie.Belkin> <20121103100447.GA2003@elie.Belkin>
	 <20121113.031446.1481052044099452015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ua5du1jNVhzzXL3vXicH"
Cc: jrnieder@gmail.com, jdg@debian.org, mlindner@marvell.com,
	shemminger@vyatta.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54902 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750835Ab2KNFtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 00:49:17 -0500
In-Reply-To: <20121113.031446.1481052044099452015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ua5du1jNVhzzXL3vXicH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-11-13 at 03:14 -0500, David Miller wrote:
> From: Jonathan Nieder <jrnieder@gmail.com>
> Date: Sat, 3 Nov 2012 03:04:48 -0700
>=20
> > On October 25, Jonathan Nieder wrote:
> >> Mirko Lindner wrote:
> >=20
> >>> Re-enable interrupts if it is not our interrupt
> >>>
> >>> Signed-off-by: Mirko Lindner <mlindner@marvell.com>
> > [...]
> >> Tested-by: Julian Gilbey <jdg@debian.org> # 3.2.y, Inspiron 1545
> >=20
> > Ping.  Dave, is
> >=20
> >   d663d181b9e9 sky2: Fix for interrupt handler
> >=20
> > a candidate for inclusion in 3.0-, 3.2-, and 3.4-stable?  (It was
> > applied upstream during the 3.6 merge window.)  I don't see it in
> > the list at [2].
>=20
> This looks fine.

Queued up for 3.2, thanks all.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-Ua5du1jNVhzzXL3vXicH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUKMwzOe/yOyVhhEJAQpFPhAAhIdK6k5vQFYrLDcI5LipAP2D4Qs6TTEp
mOYQ77Pndhvi6pUY48fkh6Jq4zKsmG+Hg7t8QOxJDUvtbyDpaw1fShleLv1KmOgS
V3J7dJNOWvMLby4WjKcWHZhlyF8PTq75FjBH+q1HLZEOuVLNVcJx3QNmB9PRxECL
oogUQH8Abz7+51TDzRxn/XNoxWRrWbjOpqR4btK47mgudvQonCEcdhsmg5d5vlEM
OcvZiupIgn5iBqWcTl0e4T6ypqbUDLGMqTPTeN61dH/xRLhI6YsNFWC1ohNIH5lv
vpoFVmXyGy403vS1ihrCFPJhBflFnJko4wf4qpQQ/q1M+IEVqwaUC66fVE/no3NZ
tVv6gdwq4G/XdncC371zB97TenNwMnVq3mbQV6CgGM3IxxDIghpzdleWEDEX3y1o
YMisJiO2pfAUxL29Cw0+ueBD+CHDsoR8YpsqLLalLWuNi3f3152QJerR9mTln/Cw
t/xZLJCfYaG7zJnj0pha4uekDCfHuzqiWi3Mba1J74PFLazaiBbOuxjvBIl6aRuU
pRISt1iZUekIMOha7uHYS2sFB8iRsnL27KhaYrnIisOcdal+QYCAzkmvBJya90Ol
yCwN5o6mB+Uvz/vPlP6CKRugxwp6jPccAW2Gy1ZTN1WAaexLD439AG1M+V6+BUD+
PUPEbCIJE98=
=M3mT
-----END PGP SIGNATURE-----

--=-Ua5du1jNVhzzXL3vXicH--
