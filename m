From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2016-02-26
Date: Fri, 26 Feb 2016 08:50:50 +0100
Message-ID: <56D003DA.1090005@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="466KiUU2NdRb9fQiT8qQcS2fpj8CQXLx0"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--466KiUU2NdRb9fQiT8qQcS2fpj8CQXLx0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 3 patch for net-next/master.

There are two patches by Simon Horman, in which the device tree support
for the rcar_can driver is improved. One patch by me fixes the bad
coding style of the ems_usb driver which was introduced recently.

regards,
Marc

---

The following changes since commit 8d3f2806f8fbd9b222b3504580b5eaa9ba2964=
b8:

  Merge branch 'ethtool-ksettings' (2016-02-25 22:07:00 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.6-20160226

for you to fetch changes up to f71096dfd129e4ad1ae80cd10d5ac050e5730f8a:

  can: rcar: add device tree support for r8a779[234] (2016-02-26 08:43:34=
 +0100)

----------------------------------------------------------------
linux-can-next-for-4.6-20160226

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: ems_usb: fix coding style

Simon Horman (2):
      can: rcar: add gen[12] fallback compatibility strings
      can: rcar: add device tree support for r8a779[234]

 Documentation/devicetree/bindings/net/can/rcar_can.txt | 11 ++++++++++-
 drivers/net/can/rcar_can.c                             |  2 ++
 drivers/net/can/usb/ems_usb.c                          |  8 +++-----
 3 files changed, 15 insertions(+), 6 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--466KiUU2NdRb9fQiT8qQcS2fpj8CQXLx0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW0APbAAoJED07qiWsqSVqiIoIAJTOzd4WyNeGCyatXGUT26AF
pi3QKsABz0A3gMIYlEaJfSYEyQkVjP9+rbWX5UCZi/CTz44BE+bSXyvd4yYWggfJ
josIvU1Af9cQ++Lpti6jogRoFvLxmPF/VKj2xjGNsZqhERzn3T8+czsdcLgzK66P
PiABN3y7ra5b2lMOO7rIFzf2ZmxJ9TZ3dPh2+z5nrWKFZMjP5wh9Ghht8fJZhfoJ
4s5DOpRwgzWuBrgccCxqzSFxVZ7bFmR6yiZClEx57HOJWDBA0ZGhjyiHTZUPS+qM
s/iRlvBnjlHiu8HGQOW+L+qwUnOeuO4n/j/NkIsf4Sia6RqT+78Y2Ny12LqUNUs=
=vTYh
-----END PGP SIGNATURE-----

--466KiUU2NdRb9fQiT8qQcS2fpj8CQXLx0--
