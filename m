From: Harald Welte <laforge@gnumonks.org>
Subject: Re: ip6t_LOG.c: patch killing spaces on ouput of IPv4 address on TUNNEL=
Date: Mon, 14 Mar 2005 09:06:28 +0100
Message-ID: <20050314080628.GE19298@obroa-skai.de.gnumonks.org>
References: <DB755B5F6CF46771B8607810@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hcut4fGOf7Kh6EdG"
Cc: Maillist netdev <netdev@oss.sgi.com>, David Miller <davem@redhat.com>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <DB755B5F6CF46771B8607810@worker.muc.bieringer.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--hcut4fGOf7Kh6EdG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Mar 05, 2005 at 05:01:53PM +0100, Peter Bieringer wrote:
> Hi,
>=20
> I'm still wondering that this was never fixed since 3 years:

Because it presumably breaks existing scripts that expect it to be in
the broken (speced) format.

I'm not particularly for or against that change... but whatever I do,
somebody will always be complaining.  To make you happy and have someone
else complain next time ;)

Signed-off-by: Harald Welte <laforge@netfilter.org>

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--hcut4fGOf7Kh6EdG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCNUYEXaXGVTD0i/8RAnl8AJwN3JUwaAPT8gQzzAYMxY2gm7lGIACgq5tN
3SV5q4TW3C4v+44aVcXmNzc=
=lBrC
-----END PGP SIGNATURE-----

--hcut4fGOf7Kh6EdG--
