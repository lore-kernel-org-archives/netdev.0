From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 0/5] sis900 debugging and revision code
Date: Sun, 12 Dec 2004 13:18:52 +0100
Message-ID: <20041212121852.GA16325@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

New set of patches, following Jeff comments on my previous posts.
Patches are tested and are against latest netdev-2.6 tree

After applying all these patches you get:
- sis900 debug output filtered with netif_msg macros
- ethtool support for changing debug output
- Correct printk() logging level
- simplification of chip revision code

As usual they are available also from:
http://teg.homeunix.org/sis900.html

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBvDcs2rmHZCWzV+0RArG+AJ9IqbeS7uY0SCP9cqxH60eQQKnY3wCgr3nU
7y1VayxoWHUAdOLTib1nKpk=
=3y+R
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
