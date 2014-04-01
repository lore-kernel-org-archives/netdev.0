From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch 00/12] can: c_can: Fix a series of serious bugs and improve
 the performance
Date: Tue, 01 Apr 2014 11:09:31 +0200
Message-ID: <533A824B.1050304@pengutronix.de>
References: <20140318171007.528610837@linutronix.de> <alpine.DEB.2.02.1403312355280.14882@ionos.tec.linutronix.de> <533A742F.4090703@pengutronix.de> <alpine.DEB.2.02.1404011106020.14882@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="EXfBg9Ejri3goSdg7v9gTqhrCmIDV6eIx"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1404011106020.14882@ionos.tec.linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EXfBg9Ejri3goSdg7v9gTqhrCmIDV6eIx
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/01/2014 11:07 AM, Thomas Gleixner wrote:
>>> What's the state of this series?
>>
>> I'll apply your patches today.
>=20
> Thanks! Please drop the last one which was not part of the series:
>=20
> 	Subject: can: c_can: Reduce interrupt load by 50%
>=20
> While it works like a charm, we've seen an odd case were TX started to
> stall. Had not yet time to dig into that.

Okay, thanks for the update.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--EXfBg9Ejri3goSdg7v9gTqhrCmIDV6eIx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEUEARECAAYFAlM6gk8ACgkQjTAFq1RaXHMGVQCgl9biL53XylEt6alUD/4TZnnq
QiIAl1aQ1bPKFEVVccXiudayizgcHE4=
=se/I
-----END PGP SIGNATURE-----

--EXfBg9Ejri3goSdg7v9gTqhrCmIDV6eIx--
