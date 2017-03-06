From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: m_can: enable transmission of FD frame on latest
 version
Date: Mon, 6 Mar 2017 11:53:08 +0100
Message-ID: <e4360c52-d62d-6c35-f691-7fcd0f74f954@pengutronix.de>
References: <20170306022143.7695-1-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="IX5UxED8QfIWdNwuu9eLI160fLvRJO1X0"
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        Wenyou Yang <wenyou.yang@microchip.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Wenyou Yang <wenyou.yang@atmel.com>,
        Wolfgang Grandegger <wg@grandegger.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170306022143.7695-1-wenyou.yang@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IX5UxED8QfIWdNwuu9eLI160fLvRJO1X0
Content-Type: multipart/mixed; boundary="xPbqXldMXSBRQ22V2rjdUnfWClhorMRHR";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Wenyou Yang <wenyou.yang@atmel.com>,
 Wolfgang Grandegger <wg@grandegger.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Quentin Schulz <quentin.schulz@free-electrons.com>,
 Wenyou Yang <wenyou.yang@microchip.com>,
 Nicolas Ferre <nicolas.ferre@atmel.com>, linux-can@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <e4360c52-d62d-6c35-f691-7fcd0f74f954@pengutronix.de>
Subject: Re: [PATCH v2] can: m_can: enable transmission of FD frame on latest
 version
References: <20170306022143.7695-1-wenyou.yang@atmel.com>
In-Reply-To: <20170306022143.7695-1-wenyou.yang@atmel.com>

--xPbqXldMXSBRQ22V2rjdUnfWClhorMRHR
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/06/2017 03:21 AM, Wenyou Yang wrote:
> Enables the transmission of CAN FD frames on M_CAN IP core >=3D v3.1.x
> and with the bit rate switching.
>=20
> Tested on M_CAN IP 3.1.0 (CREL =3D 0x31040730) of SAMA5D2 SoC.

Does this patch work still with the old version of the silicon?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--xPbqXldMXSBRQ22V2rjdUnfWClhorMRHR--

--IX5UxED8QfIWdNwuu9eLI160fLvRJO1X0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAli9P5QACgkQHv7KIOw4
HPZsGgf/UHQh4MADIYgWyI9k0oQacC5MYoOQKsmdFAjQTa2ilq031CPDCKvOBR3D
RwnKR9+382gYPf/pyPj0jC/SeBVrQi5HIV4qCkzdJLbXUosRapNxQzxsWApfv2bw
lgB1xcsp0AV7lGooPDpqss8KN4PY0xfLNIBheGvijxeys9gYLh0NatzhXCtdWIpB
q24a902TSpGeTAa2MiH4/C0fQQUcRxXaKc+2QATd7h8hQT9dXOKw9vzAzH4X5LBk
XA/sGvnf3VEtpsAjm3rTcqUlPFDz1vnqArYEvb0thONgYBGUt7u61+TIfN/93J+9
/CW/mYryoyGZ6nIefOt+qoQBs2HLOA==
=Gf4x
-----END PGP SIGNATURE-----

--IX5UxED8QfIWdNwuu9eLI160fLvRJO1X0--
