From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: [PATCH 0/3] prism54: remove some module_params,
	WE17 and initial WPA work
Date: Thu, 19 Aug 2004 18:54:24 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040819225424.GY6044@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1553318368=="
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


--===============1553318368==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="R6sEYoIZpp9JErk7"
Content-Disposition: inline


--R6sEYoIZpp9JErk7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Jeff,

The following patches go ontop of Margit's recent patches which have not
yet been integrated by you. These patches add remove some unncessary
module_params, adds WE17 support and adds our initial WPA work --
striving to get prism54 wpa_supplicant to work with prism54.

Please note that these patches are for *both* 2.6 and 2.4.

Thanks,

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--R6sEYoIZpp9JErk7
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBJS+gat1JN+IKUl4RAhJwAJ9SCtvXveHFVVizhdVe38pe5s3KlQCgi+9/
sPytIakTScWq0ginITGNeQ4=
=7ZfL
-----END PGP SIGNATURE-----

--R6sEYoIZpp9JErk7--

--===============1553318368==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1553318368==--
