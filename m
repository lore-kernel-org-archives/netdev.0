From: Harald Welte <laforge@netfilter.org>
Subject: Re: [RFC] IPv4 Netfilter hook priorities for SELinux
Date: Tue, 6 Jan 2004 20:13:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040106191311.GH934@obroa-skai.de.gnumonks.org>
References: <Xine.LNX.4.44.0401061046390.7530-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="U3s59FfKcByyGl+j"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        "David S. Miller" <davem@redhat.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0401061046390.7530-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--U3s59FfKcByyGl+j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 06, 2004 at 11:01:03AM -0500, James Morris wrote:
=20
> Does anyone have any objections to the patch below (which I'd propose for=
=20
> 2.6.2), or other comments?

Thanks James, I am perfectly fine with your patch.  Feel free to put
them into netfilter_arp.h and netfilter_ipv6.h, too.

> - James

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--U3s59FfKcByyGl+j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/+wjGXaXGVTD0i/8RAjFRAJ9Mub15xR+99zCM+eZgCi04/P3XCACeLCmI
B9EEK83mrXSiQN6i549VcP4=
=vGvz
-----END PGP SIGNATURE-----

--U3s59FfKcByyGl+j--
