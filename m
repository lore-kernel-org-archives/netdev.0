From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-07-11
Date: Wed, 11 Jul 2012 16:05:25 +0200
Message-ID: <4FFD8825.2060109@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6F2091B0789EAE0B317C1DE5"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6F2091B0789EAE0B317C1DE5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

the fourth pull request for upcoming v3.6 net-next consist of a series
of can_gw netlink cleanups done by Thomas Graf.

regards, Marc

--

The following changes since commit 061a5c316b6526dbc729049a16243ec27937cc=
31:

  Merge branch 'davem-next.r8169' of git://violet.fr.zoreil.com/romieu/li=
nux (2012-07-09 16:09:47 -0700)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 5d91efa8dd8ced8647798d067f2ac8125194be58:

  can: gw: Remove pointless casts (2012-07-10 22:36:17 +0200)

----------------------------------------------------------------
Thomas Graf (4):
      can: gw: Don't bump nlmsg_len manually
      can: gw: Use nla_policy to validate netlink attributes
      can: gw: Properly fill the netlink header when responding to RTM_GE=
TROUTE
      can: gw: Remove pointless casts

 net/can/gw.c |   90 +++++++++++++++++++++-------------------------------=
------
 1 file changed, 33 insertions(+), 57 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig6F2091B0789EAE0B317C1DE5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/9iCwACgkQjTAFq1RaXHP7DgCfRlK6VBWWsvVsTTCXXtdLqU/8
+zMAmwX54Mt4x30cwer/zZCCifQtfuRm
=E9sA
-----END PGP SIGNATURE-----

--------------enig6F2091B0789EAE0B317C1DE5--
