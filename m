From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Prism54 1.2 is out
Date: Wed, 23 Jun 2004 02:37:37 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040623063737.GW6253@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1215842476=="
Cc: Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <prism54-devel-bounces@prism54.org>
To: prism54-devel@prism54.org
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


--===============1215842476==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XAEV7zm15O60d1Zf"
Content-Disposition: inline


--XAEV7zm15O60d1Zf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Quick notice to developers. Prism54 1.2 is out, cvs was tagged with
rel-1-2. The 2.6.7-bk3 and 2.6.7-mm1 have prism54 1.2. I just submitted
prism54 1.2 to Andrew for the 2.4 stock kernel.

Patches and development improvements are now welcomed but from now=20
on please submit any changes/patches for verification first
with netdev. If accepted then apply to CVS. We're no longer a cheap'ol
driver, our changes need to be reviewed by the good guys now ;)=20

If you're not subscribed to netdev and you are a prism54 developer,=20
please do so as prism54 development discussion should take place there now.
We'll still use prism54 devel for archiving purposes (CC's to netdev).

I've put some notes on the prism54.org page, if I forgot
something/someone I'm sorry, please e-mail me. I'll go ahead now and=20
null out the ChangeLog so we can start 1.3 work.=20

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--XAEV7zm15O60d1Zf
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA2SUxat1JN+IKUl4RAtK2AJ9UXMNS5lNoxHwL1MQ+ruIGEOrbhgCgjO3g
B3nvESbxox3mH54FpxxtANw=
=7fzh
-----END PGP SIGNATURE-----

--XAEV7zm15O60d1Zf--

--===============1215842476==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1215842476==--
