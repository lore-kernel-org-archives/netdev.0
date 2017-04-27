From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2017-04-25
Date: Thu, 27 Apr 2017 09:54:33 +0200
Message-ID: <17d73df9-8f7a-1458-c4f8-e8153be206d5@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="1sqxFFC5tn9RH0Lnf6Rh24P6kiUe6jxm7"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48249 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966885AbdD0Hyn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 03:54:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1sqxFFC5tn9RH0Lnf6Rh24P6kiUe6jxm7
Content-Type: multipart/mixed; boundary="CWK4jQulB1Uxrl5JBTXV4T6KMTNwRTXcF";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <17d73df9-8f7a-1458-c4f8-e8153be206d5@pengutronix.de>
Subject: pull-request: can-next 2017-04-25

--CWK4jQulB1Uxrl5JBTXV4T6KMTNwRTXcF
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 1 patch for net-next/master.

This patch by Oliver Hartkopp fixes the build of the broad cast manager
with CONFIG_PROC_FS disabled.

regards,
Marc

---

The following changes since commit b1513c35317c106a1588f3ab32f6888f0e2afd=
71:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-04-=
26 22:39:08 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.12-20170427

for you to fetch changes up to c2701b370e6b4d0022043691b5ac7adad015e4fc:

  can: fix CAN BCM build with CONFIG_PROC_FS disabled (2017-04-27 09:34:1=
3 +0200)

----------------------------------------------------------------
linux-can-next-for-4.12-20170427

----------------------------------------------------------------
Oliver Hartkopp (1):
      can: fix CAN BCM build with CONFIG_PROC_FS disabled

 net/can/bcm.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--CWK4jQulB1Uxrl5JBTXV4T6KMTNwRTXcF--

--1sqxFFC5tn9RH0Lnf6Rh24P6kiUe6jxm7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkBo7kACgkQHv7KIOw4
HPbliggAu3kwXrqgUQYjFonVBHz9mqPhSc8QzX36EOO3l9V/BtxsSiPvtpkDpkJE
3qH5Y8TrGe27+yVMVP9w9xotvDZeEa55cBvnChYVcZEEbZK7jm4Ycd6YQyKnpRgB
2WbXETKnxYpGjdisQe/OS4HWuM0sRIOqEvaphT7TPw88Nv2bhNOd2pE9xluzGd0n
6nlUTQXQCs+asp3cAEXfdBfcfKljl7/UGnEcUy9Fp92ZD6z5c8gHk6E/YjLZn5Hu
nw9LYAzpsWjaVGFrv2I+WVocT6Ri6lulcK4JfjkwuNkbXCKM5g2DV1OWa0PwUQqB
JdmG6hc5kZ8fw7Q3ZRZbGJy3lZhTkA==
=3TaK
-----END PGP SIGNATURE-----

--1sqxFFC5tn9RH0Lnf6Rh24P6kiUe6jxm7--
