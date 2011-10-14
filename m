From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/4] can: the mailinglist moved to vger.kernel.org
Date: Fri, 14 Oct 2011 11:20:52 +0200
Message-ID: <4E97FEF4.8030806@pengutronix.de>
References: <1318581817-12352-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD4B2890E70C854246C02FEC2"
Cc: linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35829 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab1JNJU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 05:20:59 -0400
In-Reply-To: <1318581817-12352-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD4B2890E70C854246C02FEC2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/14/2011 10:43 AM, Marc Kleine-Budde wrote:
> Hello,
>=20
> the BerliOS project will close with the end of the year, so we moved ou=
r
> mailinglist to vger.kernel.org, it's now linux-can@vger.kernel.org.
>=20
> This patch series changes every mail address accordingly.

The following changes since commit 7ae60b3f3b297b7f04025c93f1cb2275c3a1df=
cd:

  sky2: fix skb truesize underestimation (2011-10-13 17:12:46 -0400)

are available in the git repository at:
  git.pengutronix.de:/git/mkl/linux-2.6.git can/mailinglist-for-net-next

Marc Kleine-Budde (4):
      MAINTAINERS: can: the mailinglist moved to vger.kernel.org
      drivers/net/can: the mailinglist moved to vger.kernel.org
      net/can: the mailinglist moved to vger.kernel.org
      include/linux/can: the mailinglist moved to vger.kernel.org

 MAINTAINERS                       |    4 ++--
 drivers/net/can/at91_can.c        |    2 +-
 drivers/net/can/sja1000/sja1000.c |    2 +-
 drivers/net/can/sja1000/sja1000.h |    2 +-
 drivers/net/can/slcan.c           |    2 +-
 drivers/net/can/vcan.c            |    2 +-
 include/linux/can.h               |    2 +-
 include/linux/can/bcm.h           |    2 +-
 include/linux/can/core.h          |    2 +-
 include/linux/can/dev.h           |    2 +-
 include/linux/can/error.h         |    2 +-
 include/linux/can/gw.h            |    2 +-
 include/linux/can/netlink.h       |    2 +-
 include/linux/can/raw.h           |    2 +-
 net/can/af_can.c                  |    2 +-
 net/can/af_can.h                  |    2 +-
 net/can/bcm.c                     |    2 +-
 net/can/gw.c                      |    2 +-
 net/can/proc.c                    |    2 +-
 net/can/raw.c                     |    2 +-
 20 files changed, 21 insertions(+), 21 deletions(-)

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD4B2890E70C854246C02FEC2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6X/voACgkQjTAFq1RaXHPl+ACeKYNpLUnjRGRF9B3SA6cuh+ni
3SQAn00g6OmqTtdOVw2fQ45ecezivubq
=uqCU
-----END PGP SIGNATURE-----

--------------enigD4B2890E70C854246C02FEC2--
