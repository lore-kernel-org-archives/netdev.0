From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] 2/2:  Fix NAT helper locking
Date: Sat, 4 Sep 2004 22:05:18 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040904200518.GC11414@obroa-skai.de.gnumonks.org>
References: <20040903070234.GQ26263@sunbeam.de.gnumonks.org>
	<20040903002453.77beee16.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="adJ1OR3c6QgCpb/j"
Cc: Harald Welte <laforge@netfilter.org>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040903002453.77beee16.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--adJ1OR3c6QgCpb/j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 03, 2004 at 12:24:53AM -0700, David S. Miller wrote:
=20
> Ummm... wow what ancient tree did you patch against
> Harald?  The tree you patched against didn't even have the
> skb_header_pointer() changes in it, that's caveman
> era :-)  That's what caused the rejects.

I tried to apply the patch against 2.6.9-rc1 before sending it to you.
It had offsets, but applied cleanly

> Thanks.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--adJ1OR3c6QgCpb/j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBOh/+XaXGVTD0i/8RAgXLAJ4tcjBuw7+0CoQGe1FK9Dc1/2LB+ACbBtxK
8sWfs0Pl9hdUDYNq+oDE+KA=
=k3Xl
-----END PGP SIGNATURE-----

--adJ1OR3c6QgCpb/j--
