From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH 0/14] prism54: bring up to sync with prism54.org cvs rep
Date: Mon, 24 May 2004 04:57:27 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040524085727.GR3330@ruslug.rutgers.edu>
References: <20040524083003.GA3330@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NfRCDefLLAVdwZEC"
Return-path: <prism54-devel-admin@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	prism54-devel@prism54.org
Content-Disposition: inline
In-Reply-To: <20040524083003.GA3330@ruslug.rutgers.edu>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org


--NfRCDefLLAVdwZEC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


BTW we can supply a 2.4 prism54 patch (as new driver). Would that be
wanted?

	Luis

On Mon, May 24, 2004 at 04:30:03AM -0400, Luis R. Rodriguez wrote:
>=20
> Jeff,
>=20
> Please apply the following patches to linux-2.6.7-rc1. These patches
> bring the kernel tree up to sync with prism54.org's 1.2's release.
>=20
> [PATCH 1/14 linux-2.6.7-rc1] prism54: add new private ioctls
> [PATCH 2/14 linux-2.6.7-rc1] prism54: reset card on tx_timeout
> [PATCH 3/14 linux-2.6.7-rc1] prism54: add iwspy support
> [PATCH 4/14 linux-2.6.7-rc1] prism54: add support for avs header in monit=
or mode
> [PATCH 5/14 linux-2.6.7-rc1] prism54: new prism54 kernel compatibility
> [PATCH 6/14 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 74, 75
> [PATCH 7/14 linux-2.6.7-rc1] prism54: Fix 2.4 build
> [PATCH 8/14 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 39, 73
> [PATCH 9/14 linux-2.6.7-rc1] prism54: Fix prism54.org bug 77; strengthene=
d oid transaction
> [PATCH 10/14 linux-2.6.7-rc1] prism54: Don't allow mib reads while unconf=
igured
> [PATCH 11/14 linux-2.6.7-rc1] prism54: Touched up kernel compatibility
> [PATCH 12/14 linux-2.6.7-rc1] prism54: Start using likely/unlikely
> [PATCH 13/14 linux-2.6.7-rc1] prism54: Fix 2.4 SMP build
> [PATCH 14/14 linux-2.6.7-rc1] prism54: Fix channel stats; bump to 1.2
>=20
> 	Luis
> =09
> --=20
> GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 5=
25E



--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--NfRCDefLLAVdwZEC
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAsbj3at1JN+IKUl4RAuuGAKCwQiOtqIxYMo+rXbmoLlb+ijsJ0ACeOCAH
RZ24iXAXvJ8ch413We2BgJg=
=MN82
-----END PGP SIGNATURE-----

--NfRCDefLLAVdwZEC--
