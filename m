From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Re: [PATCH 0/14] prism54: bring up to sync with prism54.org cvs rep
Date: Sat, 29 May 2004 04:38:03 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040529083803.GQ3330@ruslug.rutgers.edu>
References: <5.1.0.14.2.20040528090459.00ae3d18@pop.t-online.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qx542RXz7QAsGbWW"
Cc: prism54-devel@prism54.org, linux-netdev@vger.rutgers.edu,
	netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <prism54-devel-admin@prism54.org>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20040528090459.00ae3d18@pop.t-online.de>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org


--qx542RXz7QAsGbWW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 28, 2004 at 10:56:30AM +0200, Margit Schubert-While wrote:
> The waitq change is no problem.
> Luis, shall I update CVS ?

Please do.=20

> The other compats I assume are OK : -
> synchronize_irq is defined like that in other drivers.
> The firmware loader defines could be reduced from 2 to 1 by
> changing the parameters to isl38xx_upload_firmware. I can't
> see how to get rid of that entirely due to the parameter type
> change from 2.4 to 2.6 in the firmware loader call.

Good luck.

Jeff,

Since Margit is working on touching up her compat work she'll just
submit the patches.

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--qx542RXz7QAsGbWW
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAuEvrat1JN+IKUl4RArmXAJ9aCSlALawD35POMGVyaOGQCxmhkwCeIXHt
wKuuYGbjDCMEjbB8ywYLiwo=
=GxmE
-----END PGP SIGNATURE-----

--qx542RXz7QAsGbWW--
