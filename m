From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] more DECLARE_MUTEX() in headers crap
Date: Wed, 21 Jul 2004 16:48:11 -0400
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040721204811.GO27487@obroa-skai.de.gnumonks.org>
References: <20040620112328.GB13691@lst.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jITzwD3HDGXid3BE"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20040620112328.GB13691@lst.de>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--jITzwD3HDGXid3BE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 20, 2004 at 01:23:28PM +0200, Christoph Hellwig wrote:
> okay, the gunk we had in arp_tables is in ip6_tables and ip6_tables,
> too.  In fact those three files see to be 80% copy & paste of each
> other..

yes, we wrote ip_tables.c, and people did copy+paste ports.  Work is
being done on generalization and unification.

I'll push your patch uptream.
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--jITzwD3HDGXid3BE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA/taLXaXGVTD0i/8RAovmAJ9m7/jU+E342vfzmq0ko8SBM8+ewwCeIRt0
Xd1F8mmNnBuF0NbzKzD38tg=
=hhd/
-----END PGP SIGNATURE-----

--jITzwD3HDGXid3BE--
