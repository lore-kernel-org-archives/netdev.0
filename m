From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-04-16
Date: Tue, 16 Apr 2013 12:51:26 +0200
Message-ID: <516D2D2E.2050509@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2OTNLPLXLAPOATNNXOVOX"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2OTNLPLXLAPOATNNXOVOX
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull-request for net-next/master. It consists of a patch by
Oliver Hartkopp. In this patch he cleans up the sja1000 header file by
using a common prefix for all sja1000 defines.

regards,
Marc

---

The following changes since commit 61f47132dcba1eacf8fd8e64488d0b6d4bcbe4=
a0:

  Merge branch 'sync_multiple' (2013-04-15 16:10:53 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 06e1d1d71876c75bf4a9d3b310c1b4df34e8be69:

  can: sja1000: use common prefix for all sja1000 defines (2013-04-16 12:=
39:14 +0200)

----------------------------------------------------------------
Oliver Hartkopp (1):
      can: sja1000: use common prefix for all sja1000 defines

 drivers/net/can/sja1000/ems_pci.c     |   6 +-
 drivers/net/can/sja1000/ems_pcmcia.c  |   6 +-
 drivers/net/can/sja1000/kvaser_pci.c  |   4 +-
 drivers/net/can/sja1000/peak_pci.c    |   2 +-
 drivers/net/can/sja1000/peak_pcmcia.c |   8 +--
 drivers/net/can/sja1000/plx_pci.c     |  12 ++--
 drivers/net/can/sja1000/sja1000.c     | 126 +++++++++++++++++-----------=
------
 drivers/net/can/sja1000/sja1000.h     |  68 +++++++++---------
 8 files changed, 117 insertions(+), 115 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2OTNLPLXLAPOATNNXOVOX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFtLS4ACgkQjTAFq1RaXHPdwgCeMx7B7xFPMdly/YtEV7ErvkI9
yskAnAiTaLDRFFUdmRF2VU0NGzZTHOGK
=nITk
-----END PGP SIGNATURE-----

------enig2OTNLPLXLAPOATNNXOVOX--
