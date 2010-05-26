From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warning in Linus' tree
Date: Wed, 26 May 2010 12:04:06 +1000
Message-ID: <20100526120406.1906cecc.sfr@canb.auug.org.au>
References: <20100525114614.fd61d822.sfr@canb.auug.org.au>
	<20100524.215822.13254177.davem@davemloft.net>
	<20100525.161929.112591425.davem@davemloft.net>
	<20100525.162446.183058933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__26_May_2010_12_04_06_+1000_PwQ2G/=KdwW1ODXi"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, NeilJay@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100525.162446.183058933.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__26_May_2010_12_04_06_+1000_PwQ2G/=KdwW1ODXi
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 25 May 2010 16:24:46 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: David Miller <davem@davemloft.net>
> Date: Tue, 25 May 2010 16:19:29 -0700 (PDT)
>=20
> > Here is how I fixed this:
> >=20
> > --------------------
> > drivers/net/usb/asix.c: Fix pointer cast.
>=20
> Sorry, that only took care of one of the two warnings :-)
>=20
> This patch is better.

Thanks, looks good.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__26_May_2010_12_04_06_+1000_PwQ2G/=KdwW1ODXi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkv8gZYACgkQjjKRsyhoI8yAywCdHfuAtKNUWMgCzKaqpCJDJHdb
sPQAoIMtGvnWnswfj4fBJvfkmw/MzifC
=kiYx
-----END PGP SIGNATURE-----

--Signature=_Wed__26_May_2010_12_04_06_+1000_PwQ2G/=KdwW1ODXi--
