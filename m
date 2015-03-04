From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-03-04
Date: Wed, 04 Mar 2015 10:42:13 +0100
Message-ID: <54F6D375.8060301@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="aC26j3HE9xnO07G6SQCgV02DOsxJJxpqA"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aC26j3HE9xnO07G6SQCgV02DOsxJJxpqA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 3 patches for net-next/master.

Aaron Wu contributes three patches for the blackfin can driver, which
cleans up the driver and makes use of more platform independent code.

Marc

---

The following changes since commit 2f56f6be47dbc6883e28107edfe2f9f98f4d5a=
24:

  bridge: fix bridge netlink RCU usage (2015-03-04 00:20:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.1-20150304

for you to fetch changes up to 400aff5da5f2c202e8ff2679005981583234df54:

  bfin_can: Merge header file from arch dependent location (2015-03-04 09=
:52:49 +0100)

----------------------------------------------------------------
linux-can-next-for-4.1-20150304

----------------------------------------------------------------
Aaron Wu (3):
      bfin_can: rewrite the blackfin style of read/write to common ones
      bfin_can: introduce ioremap to comply to archs with MMU
      bfin_can: Merge header file from arch dependent location

 drivers/net/can/bfin_can.c | 258 +++++++++++++++++++++++++++++++--------=
------
 1 file changed, 177 insertions(+), 81 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--aC26j3HE9xnO07G6SQCgV02DOsxJJxpqA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU9tN8AAoJECte4hHFiupU2e8QAKtWLoaw/wxcYoNCg5IB0N9T
R9a6qpiM3oFYV0im+EojYO56Qu9D7P13VA0GXfOGwsNvTW+3HXy7WE2P4Byc1/q5
mlxFY2di42pVMO5KSDe0Gj7DpNpnH2XYxvWRgaTB6jkusPFHCus+yiF14Fyk7J++
UnwLdN9y4vzYtZUP0Ma4U4TRabJrN0E2PB/hIi/XTpTmiDiB/c3n9cq9CuryGlTP
6h0Ja75wgtzAohvYcEMzSbdcW5LjfyQoAnkA0roYU8u94j2GH5darYtrISQ2535z
XwoJyhgx3c0Ig+bDnqK027yI/gL9uSwkXdda+pOAYKzLIBNm6cqp9XU+0rtCl+ug
qWahVj8/iHM0MDtRQpEiYCbqM7bcwS6olkxnZMKtNTg7KokKeWh4LMvg3N9+WkHB
j/82wLswzQdgXbXLjx8o42kD6hQrbMr95bU58si3R2BdinpzRLWJHp8ST/GC3LQI
tmsZh1CTOdYQQzIPb/doLSJ5GnD9NG8Numm3snA91op597vnAfDGwL7zeP+X9B23
o7J/0BlJ3Dq12aNwZrQfhfAodY7fnc+bsSMAd9MVOogbzq2wKycPlFLgoBMVuUvT
SZhnj/zqSrwdMEPNhgDIXEIpNghB4y2pXX93JSRYFCG9qZ1gETZDbgkgEywhm+HQ
3aekitvcOTZ+HRbpwifA
=GAPp
-----END PGP SIGNATURE-----

--aC26j3HE9xnO07G6SQCgV02DOsxJJxpqA--
