From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Wed, 21 Jan 2015 23:59:23 +0100
Message-ID: <54C02F4B.80206@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150120214409.GA16828@linux> <20150120214537.GB16828@linux> <20150121162025.2933.13836@shannon>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="RDI9WnV1OXD0kPIB5OW2DlPNhwP12bW0V"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andri Yngvason <andri.yngvason@marel.com>,
	"Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150121162025.2933.13836@shannon>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RDI9WnV1OXD0kPIB5OW2DlPNhwP12bW0V
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/21/2015 05:20 PM, Andri Yngvason wrote:
> Marc, could you merge the "move bus_off++" patch before you merge this =
so that I
> won't have to incorporate this patch-set into it?

=2E..included in the lastest pull-request to David. Use
tags/linux-can-next-for-3.20-20150121 of the can-next repo as you new bas=
e.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--RDI9WnV1OXD0kPIB5OW2DlPNhwP12bW0V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIbBAEBCgAGBQJUwC9LAAoJECte4hHFiupUjiIP+KOIYJJSrzy2eOxJ3DdT2Gw3
l2Z/eWRLaGdmS8POet0j+D88AHSFxMnvjqICK8aYnLshZLMb2Ot3/acaSO1MQacU
QTFSABEjWkpemtWvLDbuq9dJrxnrxAoqE6uDQDYqrIQOAsY7UrmhGyWP+fnpnqGY
4fpgNKqFHaP7x8oo7HN6CP4kSKHvUfCXA096TPeKXYSH7HWhWI73TpcBkSOt1tQU
dR2NCvYh0aE98frKOA0P9d4klqn89XAClnhGZBIF4Ncqse3S90onc7ratmanbEiK
xen2aqhGyY8K3qNEUdDKwKNBFQIZNp3/V/INFWP9R7s4FhvYTuLTwgElvT5MEqsv
rLI3JXUSUp+waJ2fpeGG+34aS0VskmkECceI4gr2x5FJPMj+ZWXk5fMB2tEIHXMK
8nuZx1TfKIcjflVGmxg0zISQdNx2qD9aNiAPoxyDm/Fq+mZTEgE0uADvNM3e4Udu
xDcG8BTep+RIVfzCeHcJWmusRK+zg+7TRdfOhnu3tvxlc+9X1bqyKWwREiDwUuej
OFlPow/8dwmBeuUVLCy0i1T7Frc+0KT4q1LkPQzyB4ouzQwQlBMdhSqL8ns7uFR8
TiL49tV/MisTFtKexi7zPjGNl1lAp8oul7gBEU8MRgvTDtnChzVyX4BppnGYx45w
KWKm8csFCKMt1rqoIEo=
=IDWz
-----END PGP SIGNATURE-----

--RDI9WnV1OXD0kPIB5OW2DlPNhwP12bW0V--
