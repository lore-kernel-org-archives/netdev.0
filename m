From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 00/16] Support for =?UTF-8?B?RWJlcnNww6RjaGVyIEZsZXhj?=
 =?UTF-8?B?YXJkIERDQU4gZnVuY3Rpb24=?=
Date: Mon, 09 Sep 2013 09:54:11 +0200
Message-ID: <522D7EA3.3040505@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="wvU5FDf9VJnm36aHCuuDXHXsOCbQQOiJ7"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wvU5FDf9VJnm36aHCuuDXHXsOCbQQOiJ7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hey Bene,

On 09/09/2013 09:24 AM, Benedikt Spranger wrote:
> The Ebersp=C3=A4cher Flexcard is a multifunctional PCI Mezzanine Card. =
This
> patch-series adds support for the DCAN function. The Flexcard supports
> up too 8 CAN devices and has some CAN related special features:
> - own FIFO per device
> - DMA for receiving CAN frames
> - Firmware tracks CAN echo packets

Please include linux-can@vger.kernel.org when posting CAN related patches=
=2E

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--wvU5FDf9VJnm36aHCuuDXHXsOCbQQOiJ7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItfqcACgkQjTAFq1RaXHMXZgCfXlABJAStcVNlmMArNI6CHfO7
8TMAnjhwETz6FJIkYzU42T1pAghFpkTj
=jlGl
-----END PGP SIGNATURE-----

--wvU5FDf9VJnm36aHCuuDXHXsOCbQQOiJ7--
