From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-11-23
Date: Mon, 23 Nov 2015 09:54:22 +0100
Message-ID: <5652D43E.2010607@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="H7AFi14s8dkWC3nJf4F76rkmscOMTuSXf"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:41567 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbbKWIya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 03:54:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--H7AFi14s8dkWC3nJf4F76rkmscOMTuSXf
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of a single patch for net-next/master.

The patch by Kedareswara rao Appana converts the xilinx CAN driver to
runtime_pm.

Marc

---

The following changes since commit 3f8c0f7efb4fcac11f31afa97584d06118c614=
bb:

  gianfar: use of_property_read_bool() (2015-11-22 20:47:14 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.5-20151123

for you to fetch changes up to 4716620d1b6291ce45522d1346c086f76b995d1c:

  can: xilinx: Convert to runtime_pm (2015-11-23 09:51:34 +0100)

----------------------------------------------------------------
linux-can-next-for-4.5-20151123

----------------------------------------------------------------
Kedareswara rao Appana (1):
      can: xilinx: Convert to runtime_pm

 drivers/net/can/xilinx_can.c | 176 +++++++++++++++++++++++++------------=
------
 1 file changed, 101 insertions(+), 75 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--H7AFi14s8dkWC3nJf4F76rkmscOMTuSXf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWUtQ+AAoJEP5prqPJtc/H9tsIAJFRTytgIuzgdPvCavAvM51x
VgKEMgGCtphhLTGSKUBZvJoKdwP9T+O587YxoMo/UXBdv/nTOFAlAiZ6XCRCDmGz
NTJX9ldEtT9zAa46C5VbpJfPssTBGOnO8w4476BF56JSXzHijuadnQxSUnVlpps0
QRm+gKvSqgG8uuBAhCraAgbMSxGXaSnWmjoeOR5lLpk8AFNWsLhZrqGpGGMC52rF
Dl1rETEiDQy8sXmN0plcaZl1Ta9KqVkfWgLOuUBB93GBpslPdSTiWWyT71TMtOf5
eUF+czgVerrz1qAuZhAN+BPFt8wzntRHupAY9rBo6gje46nPkDwNOE/wW6RVHmA=
=ANU4
-----END PGP SIGNATURE-----

--H7AFi14s8dkWC3nJf4F76rkmscOMTuSXf--
