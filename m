From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [Prism54] CVS -> bk tree update
Date: Tue, 15 Jun 2004 22:20:08 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040616022008.GM6253@ruslug.rutgers.edu>
References: <20040614191651.GC6253@ruslug.rutgers.edu>
	<40CE2754.1020109@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0009971235=="
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40CE2754.1020109@pobox.com>
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


--===============0009971235==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="at6+YcpfzWZg/htY"
Content-Disposition: inline


--at6+YcpfzWZg/htY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 14, 2004 at 06:31:48PM -0400, Jeff Garzik wrote:
> Luis R. Rodriguez wrote:
> >Hey Jeff,
> >
> >was wondering what the status of the latest prism54 patches is. Did all
> >go through cleanly, are we in-sync now? Are there patches you're still
> >reviewing?
>=20
>=20
> Check Andrew's -mm tree and see if there's anything missing.
>=20
> 	Jeff

Thanks Jeff. I did, and a diff of Andrew's -mm tree Vs our cvs tree
2.6.7-prism54 gives a 1898 line diff. This is excluding spaces,
newlines, and tabbing and all of Andew's .orig, .rej's.=20

This time it's going to be a *real* pain to provide a changelog and split t=
he
diffs.. so can I just send you that 1898 line diff and then another for
space changes? Everything has already been reviewed on the lists here...

I promise this will be our last big patch too. I'll ask our team
to send patches from now on to netdev after each ChangeLog entry, for
more public review and to not loose sync of our trees. Let us know if
you think we should do otherwise.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--at6+YcpfzWZg/htY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAz65Yat1JN+IKUl4RAsYhAJ9UkRve/oHwmnpoyNEytlqrRbm4CwCgo289
0z2OySyPiczVe6y+IIE01Yg=
=j48N
-----END PGP SIGNATURE-----

--at6+YcpfzWZg/htY--

--===============0009971235==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0009971235==--
