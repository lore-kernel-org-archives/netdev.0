From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Tue, 05 Oct 2010 13:08:34 +0200
Message-ID: <4CAB0732.3010400@pengutronix.de>
References: <4C9C7C6F.1000003@dsn.okisemi.com>	<4CA4541F.5040804@grandegger.com>	<000401cb614f$c932c750$66f8800a@maildom.okisemi.com>	<4CA5D6D7.3010608@grandegger.com> <000401cb6477$25a0eba0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF5F5E8C1BBEF943F73724D22"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	andrew.chih.howe.khor@intel.com, qi.wang@intel.com,
	margie.foster@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yong.y.wang@intel.com,
	socketcan-core@lists.berlios.de, kok.howg.ewe@intel.com,
	joel.clark@intel.com,
	Tomoya MORINAGA <morinaga526@dsn.okisemi.com>,
	meego-dev@meego.com, "David S. Miller" <davem@davemloft.net>,
	Christian Pellegrin <chripell@fsfe.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38719 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510Ab0JELIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 07:08:45 -0400
In-Reply-To: <000401cb6477$25a0eba0$66f8800a@maildom.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF5F5E8C1BBEF943F73724D22
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/05/2010 12:21 PM, Masayuki Ohtake wrote:
> Hi Wolfgang,
>=20
> I could confirm below.
> With FIFO mode, it is able to receive packet with in-order.
> We are now implementing FIFO mode.

If FIFO is working you might also think about NAPI.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF5F5E8C1BBEF943F73724D22
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkyrBzUACgkQjTAFq1RaXHPxgQCeLYKY3I9Bin2bJxzI1eMcNj/7
LucAnix4ygjGlt1exbjpdaMuuuY4zdbw
=2fP0
-----END PGP SIGNATURE-----

--------------enigF5F5E8C1BBEF943F73724D22--
