From: Alex Samad <alex@samad.com.au>
Subject: Re: kernel oops when system under network stress
Date: Thu, 16 Oct 2008 18:09:34 +1100
Message-ID: <20081016070934.GA10150@samad.com.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net> <20081016050810.GA8240@samad.com.au> <20081016064142.GA5064@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081016064142.GA5064@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 16, 2008 at 02:41:42PM +0800, Herbert Xu wrote:
> On Thu, Oct 16, 2008 at 04:08:10PM +1100, Alex Samad wrote:
> >
> > The thing to note was (for example), when I was doing a nfs transfer, it
> > would not be nfs that would crash, it would be other network based
> > application that would cause the problem, for ex sshd, apache etc
>=20
> So are you able to reproduce this at will?
just about, within a 5-10 min window


>=20
> Thanks,
> --=20
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>=20

--=20
"I don't think we need to be subliminable about the differences between our=
 views on prescription drugs."

	- George W. Bush
09/12/2000
Orlando, FL

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkj26KsACgkQkZz88chpJ2PLdACgzyDGfKhu6GEEGVeeCvSZ4qNy
gs4An1A0wjkdg221aKvbD03vU6V/G/Bz
=8GoP
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
