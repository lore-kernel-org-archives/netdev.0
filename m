From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: [PATCH 0/4] prism54: remove some module_params,
	WE17 and initial WPA work
Date: Sun, 5 Sep 2004 02:45:58 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040905064558.GT31207@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0161945945=="
Cc: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>
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


--===============0161945945==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ctP54qlpMx3WjD+/"
Content-Disposition: inline


--ctP54qlpMx3WjD+/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


[ Note: I'm resending these as Jeff's HD died ]

Jeff,                                                                      =
                         =20
                                                                           =
                         =20
The following patches go ontop of Margit's recent patches which have not   =
                         =20
yet been integrated by you. These patches add remove some unncessary       =
                         =20
module_params, adds WE17 support and adds our initial WPA work --          =
                         =20
striving to get prism54 wpa_supplicant to work with prism54.               =
                         =20
                                                                           =
                         =20
Please note that these patches are for *both* 2.6 and 2.4.                 =
                         =20
                                                                           =
                         =20
Thanks,                                                                    =
                         =20
                                                                           =
                         =20
        Luis=20

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--ctP54qlpMx3WjD+/
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBOrYmat1JN+IKUl4RAprmAKCoB+ioyNxT3fGzKg+e5EWPCorzKwCeJC9C
DHiJKtT7d+2+wU7JFuR9Jok=
=yZXR
-----END PGP SIGNATURE-----

--ctP54qlpMx3WjD+/--

--===============0161945945==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0161945945==--
