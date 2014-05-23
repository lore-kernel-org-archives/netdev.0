From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-05-23
Date: Fri, 23 May 2014 09:22:00 +0200
Message-ID: <537EF718.2020203@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="p1LMreKut4VUrPfmmfenTdaMuSKxR4Eks"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37145 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbaEWHWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 03:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--p1LMreKut4VUrPfmmfenTdaMuSKxR4Eks
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of two patches for net-next/master. Kedareswara
rao Appana contributes support for the xilinx CAN core found on the
zynq and microblaze SOCs.

Marc

---
The following changes since commit 091b64868b43ed84334c6623ea6a08497529d4=
ff:

  Merge branch 'mlx4-next' (2014-05-22 17:17:34 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.16-20140523

for you to fetch changes up to 05be386b709b5feacfaa0d3582dca63e1e435b26:

  can: xilinx CAN controller support (2014-05-23 08:59:21 +0200)

----------------------------------------------------------------
linux-can-next-for-3.16-20140523

----------------------------------------------------------------
Kedareswara rao Appana (2):
      can: Add xilinx CAN device tree bindings documentation
      can: xilinx CAN controller support

 .../devicetree/bindings/net/can/xilinx_can.txt     | 44 ++++++++++++++++=
++++++
 drivers/net/can/Kconfig                            |  8 ++++
 drivers/net/can/Makefile                           |  1 +
 3 files changed, 53 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/xilinx_can.=
txt

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




--p1LMreKut4VUrPfmmfenTdaMuSKxR4Eks
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlN+9xgACgkQjTAFq1RaXHMqHgCZAcM8qn+WAku0dAeAx8ecw4O1
R2kAnR6K1IaC47CMV+ZXaeY+oOBZDbvZ
=H+lp
-----END PGP SIGNATURE-----

--p1LMreKut4VUrPfmmfenTdaMuSKxR4Eks--
