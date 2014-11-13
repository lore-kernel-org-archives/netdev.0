From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V4 1/3] can: add can_is_canfd_skb() API
Date: Thu, 13 Nov 2014 11:04:56 +0100
Message-ID: <54648248.1020400@pengutronix.de>
References: <1415349914-9145-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="dwa2gn93AFKXWAgqNtl00iBWo0JvBwXR6"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415349914-9145-1-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dwa2gn93AFKXWAgqNtl00iBWo0JvBwXR6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 09:45 AM, Dong Aisheng wrote:
> The CAN device drivers can use it to check if the frame to send is on
> CAN FD mode or normal CAN mode.

Applied patches 1 and 3.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--dwa2gn93AFKXWAgqNtl00iBWo0JvBwXR6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZIJMAAoJECte4hHFiupUDH4QAJFu9/TTOSdZ1n+2B5li1Ufo
b4wbh93h6zLrMYEJf2pnVW9deyHQ9CpsFqoNILbRTyVniOeSPe6c7z98wOWvF/E2
Xgw7IyLcGB/VFE3rA8gaOmr8hKcriTEsW+Z5HKe/JwoBjqjRrsCdyI/fdBWzy6c4
IEMTn6/BeyS/wTBzGpiTGS+prstnIv+Dryx5bvTen0pps2gPlXkJQbcNRgUtU3nu
V4G44D2M8OCdBL+9ZWyiC+1OHeAAQE1nMnw0dNWdcJ7mPNrl+bV+bX5OwUzMBP7L
v9ej0N40YXDXgwGzTGXjqIX3BlZohzBMaZNUBOe/YNtHXSQgQVPMghLHjQPoe1mv
C86WpLSphmMWa4goxN/1aTWaC/Z5lvChYQrnVYUCBFISm1cHPiEeQTa1KJuEzx6+
tuSvG6AG15vwFp+egUfMjOmqRCnJZVayzWA8aVJp8tF6QBpgKrqvXLIm2z1avT62
I4GGu170mGBbMWCKV5Y8X/l/6Vi9/w2YnaWIz6NUnQsmNVgmFuZWdv9NfZCsqaFo
ZZ2cWnrjvY3euuyZ3WATkq/Bn+UVuaP9mu3Mk+zXOTIs5A+cwwZddAW0zGmGnEPm
8eG8FRJQL5KjQ0ERQawH0CCS2OXUR7fcn6E+EN9htIuH/cnz/w1qmqexXP8LkpBr
twfn+zN3HNvZgxTdBv9a
=cwUo
-----END PGP SIGNATURE-----

--dwa2gn93AFKXWAgqNtl00iBWo0JvBwXR6--
