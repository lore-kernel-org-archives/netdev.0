From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Re: [patch 2/3]
	drivers/net/wireless/prism54/islpci_hotplug: Use the DMA_{64,
	32}BIT_MASK constants
Date: Tue, 8 Mar 2005 10:22:44 -0500
Message-ID: <20050308152244.GF3936@ruslug.rutgers.edu>
References: <20050306222355.6686C1ED3D@trashy.coderock.org>
	<20050307171418.GT3936@ruslug.rutgers.edu>
	<422C8E48.9000006@pobox.com>
	<20050307172957.GW3936@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1054932060=="
To: Jeff Garzik <jgarzik@pobox.com>, domen@coderock.org,
	prism54-private@prism54.org, netdev@oss.sgi.com,
	tklauser@nuerscht.ch, prism54-devel@prism54.org
In-Reply-To: <20050307172957.GW3936@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1054932060==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Xivtt9Q8Gazzyu1i"
Content-Disposition: inline


--Xivtt9Q8Gazzyu1i
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 07, 2005 at 12:29:57PM -0500, Luis R. Rodriguez wrote:
>=20
> Alright, I'll add DMA_32BIT_MASK through compat and leave
> pci_module_init as is.  That said:
>=20
> Patch 1 applied
> Patch 2 will be applied after compat work
> Patch 3 rejected per Jeff's recomendation due to 2.4 compat
>=20
> 	Luis

This has been committed on to prism54 tree.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--Xivtt9Q8Gazzyu1i
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCLcNEat1JN+IKUl4RAscUAKCD5c1x7GVgeM87CaWQw/D7YMx3BwCeIekZ
CcImIvbt4ARf4QcDCSrhV34=
=WGO/
-----END PGP SIGNATURE-----

--Xivtt9Q8Gazzyu1i--

--===============1054932060==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1054932060==--
