From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after final merge (net tree)
Date: Fri, 19 Feb 2010 18:45:22 +1100
Message-ID: <20100219184522.b89facc7.sfr@canb.auug.org.au>
References: <20100219173713.e3f9f386.sfr@canb.auug.org.au>
	<20100218.233321.226788593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__19_Feb_2010_18_45_22_+1100_QV.B4eE8K7zWsXnv"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kristoffer@gaisler.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100218.233321.226788593.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__19_Feb_2010_18_45_22_+1100_QV.B4eE8K7zWsXnv
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 18 Feb 2010 23:33:21 -0800 (PST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 19 Feb 2010 17:37:13 +1100
>=20
> > I assume that this driver was written and tested only on Sparc
> > ... maybe it should depend on SPARC?
>=20
> Indeed, it should.  I thought for some reason that all OF
> platforms have of_remap() and of_device->resource[], oh
> well :-)
>=20
> Will commit the following, thanks!
>=20
> net: Make GRETH driver depend on SPARC.

Thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__19_Feb_2010_18_45_22_+1100_QV.B4eE8K7zWsXnv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkt+QZIACgkQjjKRsyhoI8wYpACeJUqvzMiseGEskzw6gNJkgkWf
W7oAoLbgidgt2HbDhvUF8sKAvWNLPhQ1
=zEew
-----END PGP SIGNATURE-----

--Signature=_Fri__19_Feb_2010_18_45_22_+1100_QV.B4eE8K7zWsXnv--
