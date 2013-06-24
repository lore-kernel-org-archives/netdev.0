From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Per route MTU settings are broken in linux kernel 3.2
Date: Mon, 24 Jun 2013 13:45:51 +0100
Message-ID: <1372077951.21189.16.camel@deadeye.wl.decadent.org.uk>
References: <1372063443.32157.10.camel@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5a9ETWP2FVrqRFVVCqRK"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Yura Pakhuchiy <pakhuchiy@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1372063443.32157.10.camel@linux>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-5a9ETWP2FVrqRFVVCqRK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-06-24 at 15:44 +0700, Yura Pakhuchiy wrote:
> Hello Ben,
>=20
> Looks like setting per route MTU (as described in [1]) is broken in
> Linux kernel 3.2. I tested with newer Ubuntu kernels 3.5 and 3.8 and it
> looks like problem is fixed there. I filled Ubuntu bug report [2] with
> more details and sample script which illustrates problem. But since this
> problem is probably also present in stock kernel (not just in Ubuntu),
> is it possible to backport fixes to stable 3.2 series?
>=20
> 1. http://lartc.org/howto/lartc.cookbook.mtu-discovery.html
> 2. https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1177507

Sure, what are the fixes?

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-5a9ETWP2FVrqRFVVCqRK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUcg/f+e/yOyVhhEJAQrRVRAA1P9GysjIPkzLpyOPIe1EcnW2zMAzZOK1
2au+Y1I7ZQ2vwplk3w474RR4qtBJqkz36r0MJvK8NNFg0PopEVM1XVv4QcCGsj+n
xrrQjcJqp4TJW9wytfpcIbKzTBFQTEK4w0YP83rjDrtIJPwuYnJZEKKuWHk4Npxx
0Wr7S34f1NiO77XqdJl6d7Hez1TaNTVjbyv6mxudmE2AF5IxezaAJyYTgTFIFn01
4LEui7EqBkjoQORkI+oWPcbTAfxNdIH61fxeJcJTLdZsGzT9pqZqb07tu+QtCbmU
JnWrh02HaOWCDAcm80Takp9l0RxURb9PIc1APv6el6SOWZQDDwrg/gV9kL4zjIKL
OSHCtbl30YByVhXS+z8vBjA9SvhcGFhAuXkdEmsQnMsvOtyLGnv0yZJG2vx83a6+
h4bh4d4yiFllM2XDtl7XdoVtQzuBlfVwsc4nInBDjdsUSMVHdCMREHmbMutyD5/y
YhvKn4KDoetyfhmhIWoVdnpFtUoSm3NAyUCmTleWSjnbxRsPWG0cNRZaCThI9DTx
fqw18RAZMrixr2Gj8gueDYfaKinT81jVt9D42iJcyHHCWYJEoRtDByFWGi310pC4
dC6zqygQEOsspMD1d/sMjZtIL4ACJhbHWQCAYK0mu3ybF26/3f9Q2bGQPVaUrH3d
IHSx9kQEV30=
=2LJb
-----END PGP SIGNATURE-----

--=-5a9ETWP2FVrqRFVVCqRK--
