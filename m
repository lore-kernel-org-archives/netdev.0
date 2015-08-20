From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-05-06
Date: Thu, 20 Aug 2015 14:13:53 +0200
Message-ID: <55D5C481.5050200@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="JdnlapuHAVimrSVojdbKec3F3wuTGOhDM"
Cc: linux-can@vger.kernel.org, davem@davemloft.net,
	kernel@pengutronix.de, David Jander <david@protonic.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60302 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbHTMOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 08:14:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JdnlapuHAVimrSVojdbKec3F3wuTGOhDM
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of a two patches for net-next.

The first patch is by Nik Nyby and fixes a typo in a function name. The
second patch by Lucas Stach demotes register output to debug level.

regards,
Marc

---

The following changes since commit 824e7383e92815cb591793c74cc836aa5165f7=
f8:

  lwtunnel: Fix the sparse warnings in fib_encap_match (2015-08-19 17:37:=
51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.3-20150820

for you to fetch changes up to 7a4b6c860e7268a79545c30882928b234dd1655d:

  can: flexcan: demote register output to debug level (2015-08-20 10:52:5=
4 +0200)

----------------------------------------------------------------
linux-can-next-for-4.3-20150820

----------------------------------------------------------------
Lucas Stach (1):
      can: flexcan: demote register output to debug level

Nik Nyby (1):
      can: gs_usb: Fix typo in function name

 drivers/net/can/flexcan.c    | 2 +-
 drivers/net/can/usb/gs_usb.c | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--JdnlapuHAVimrSVojdbKec3F3wuTGOhDM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV1cSCAAoJEP5prqPJtc/Hu5MH/A+fpojzSs4HTcypxoLMxk+e
3PEjQgUwH4aOwxu9Oq06+OQIw/ImjQs92KgM0jcyLQPfruqV5w3QbhOw5VwbnZyS
K1jUA7rTz97vGh27HZk65lgkUifvgGdgHCfPSSsgt+lwIFBbOflkiva1hP2Gsair
t8+LAdBU0RdZRMlfum7H1jiZTMAuVhaCBioEzqNNUeev3YpQr0E1wr9/+z4rqV63
Yzrtjlb4RY76RR7DD3xd5Ej06YwVqcBdYC+Zw37hi32yOlZYmfDoJ8SZVce+f+BB
UyaT5o79/jKsnynKx2LiccoNAABfPREikfWE7hF4TFQHH8rtbK9rZMcz54Y1idc=
=+ZS/
-----END PGP SIGNATURE-----

--JdnlapuHAVimrSVojdbKec3F3wuTGOhDM--
