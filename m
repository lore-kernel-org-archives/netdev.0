From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 5/5] sis900 printk and stack usage audit
Date: Wed, 8 Dec 2004 12:10:10 +0100
Message-ID: <20041208111010.GF31707@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oplxJGu+Ee5xywIT"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041208104721.GA31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--oplxJGu+Ee5xywIT
Content-Type: multipart/mixed; boundary="tSiBuZsJmMXpnp7T"
Content-Disposition: inline


--tSiBuZsJmMXpnp7T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Change comment to reflect changes in parameters od sis630_set_eq

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--tSiBuZsJmMXpnp7T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-sis630-docs.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 43)
+++ b/drivers/net/sis900.c	(revision 44)
@@ -1121,7 +1121,6 @@
 /**
  *	sis630_set_eq - set phy equalizer value for 630 LAN
  *	@net_dev: the net device to set equalizer value
- *	@revision: 630 LAN revision number
  *
  *	630E equalizer workaround rule(Cyrus Huang 08/15)
  *	PHY register 14h(Test)

--tSiBuZsJmMXpnp7T--

--oplxJGu+Ee5xywIT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBtuES2rmHZCWzV+0RAv3BAJ9iap/qRLxiEoc0yRXdy5kSS7RdHwCeNBdH
3X4qLtiWfkFz1ADLgpxnUJc=
=5Kxh
-----END PGP SIGNATURE-----

--oplxJGu+Ee5xywIT--
