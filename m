From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: [PATCH] wpa_supplicant: update driver_prism54.c
Date: Thu, 19 Aug 2004 19:27:20 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040819232720.GD6044@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1291563267=="
Cc: prism54-devel@prism54.org, hostap <hostap@shmoo.com>,
	Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <prism54-devel-bounces@prism54.org>
To: Jouni Malinen <jkmaline@cc.hut.fi>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1291563267==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="j3zO+32zXj6UcJCE"
Content-Disposition: inline


--j3zO+32zXj6UcJCE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Jouni,

the attached patch adds some startup work for wpa_supplicant support for
prism54. I just integrated some work for wpa_supplicant support into
prism54 CVS and sumbitted to Jeff for inclusion in 2.6 and 2.4. This
work is not yet complete but should get the ball rolling for us to
complete it.

People wishing to help advance this work should check out prism54 CVS
and use the attached patch for wpa_supplicant.

Thanks,

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--j3zO+32zXj6UcJCE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBJTdYat1JN+IKUl4RAo8zAKCVcsJ3EjQkk6eomTO+uSUdy6NXowCcDooy
nZ3olhmg6Kiayep6Fc1pc3c=
=CWio
-----END PGP SIGNATURE-----

--j3zO+32zXj6UcJCE--

--===============1291563267==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1291563267==--
