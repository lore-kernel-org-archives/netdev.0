From: Harald Welte <laforge@netfilter.org>
Subject: Re: IPv6 multicast (MLD,IGMP) code bypasses netfilter hooks
Date: Mon, 24 Nov 2003 11:24:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124102451.GJ4888@obroa-skai.de.gnumonks.org>
References: <OFBBD13E53.65F0744F-ON88256DE7.003D0DE0@us.ibm.com> <20031123224414.0bea3633.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="W/+CTqSGWdiRg+8j"
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031123224414.0bea3633.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--W/+CTqSGWdiRg+8j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 23, 2003 at 10:44:14PM -0800, David S. Miller wrote:

> David Stevens <dlstevens@us.ibm.com> wrote:
>=20
> > Here's a patch to add netfilter hooks for MLD v1 & v2. Can you take
> > quick look at it, Harald?
>=20
> Whoa, David beat me to it, on a weekend no less :)))

Thanks, David & David :)

> It looks good to me.  Applied, thanks.

obviously fine with mee, too.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--W/+CTqSGWdiRg+8j
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/wdxzXaXGVTD0i/8RAvskAKCa3uDiy7EsfvZs5+/R903R+s6otwCfU5Hz
Asp39O69bw/z9cTCgun7ujs=
=Suf4
-----END PGP SIGNATURE-----

--W/+CTqSGWdiRg+8j--
