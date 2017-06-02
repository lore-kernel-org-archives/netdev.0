From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [pull request][for-next 0/6] Mellanox mlx5 updates 2017-05-23
Date: Fri, 2 Jun 2017 18:39:40 +0300
Message-ID: <20170602153940.GX5406@mtr-leonro.local>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170525.120220.1812199263503283242.davem@davemloft.net>
 <1496357879.7171.76.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3jK+0sHr6j/jwA0V"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1496357879.7171.76.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--3jK+0sHr6j/jwA0V
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 01, 2017 at 06:57:59PM -0400, Doug Ledford wrote:
> On Thu, 2017-05-25 at 12:02 -0400, David Miller wrote:
> > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > Date: Tue, 23 May 2017 14:43:58 +0300
> >
> > > Hi Dave and Doug,
> > >=A0
> > > This series introduces some small updates and FPGA support to the
> > mlx5
> > > core/ethernet and IB drivers.
> > >=A0
> > > For more details please see below.
> > >=A0
> > > Please pull and let me know if there's any problem.
> >
> > Ok, I've pulled this into net-next.
> >
> > Doug let me know if there are any merge hassles we need to coordinate
> > on.
> >
> > Thanks.
>
> Will do. =A0But is the question of a possible revert settled? =A0Because
> once I pull, a revert means I have to pull all the way up to the revert
> as well...

Revert is unlikely to happen, Saeed is working with Alexey to resolve
his raised concerns.

Thanks

>
> --
> Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> =A0 =A0 GPG KeyID: B826A3330E572FDD
> =A0 =A0
> Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =A01274 B826 A333 0E57 2FDD
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--3jK+0sHr6j/jwA0V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkxhrwACgkQ5GN7iDZy
WKfV3xAAybbErZFaTN4vy4Av8vh54Wi9UJPsBlEAcklqmvAkO7JR0FruBBE/d3/z
XUlyEXTHiFXf/DkVGsVyM3CsDnqVSselDEzbyPY/YWrHWncWlKVnGhJlJGz4yaWL
WPvP679nBzxrn+B4OWRlO2OLmMsQkQLaQjcKROUe5JtsljISSnRRK7rlxixTOP+v
+vPCNdfW7FmA3KG6Joq/MCHWdw5mWl0axdUppCDq9eQtVvAu6U3jO+Copx2rHzCW
NT+1a32UXmWwT7Zpqs8J9izcUeP5bEPbciqoxL/5AJwuFZkieMxAoBPsKG7miLoj
0NNnZ4bN381NHaR26UxLMNi+MSVqUqUpNYsbVWVf0WJQMn9FFJPXO73uu0GzgN7j
u4SOHiOBP04+t8ZTZu6UmGcWJruJ2LDF0kV8qeMyMwHc/Lt+7msLiROzALLSf8rA
u4FDh2okjUKscFO/istDHqw0FBxGHfEKtKBsqSjonhS2VMl/d7+AVhdXg2jXRQWk
SMGgF5F7A2DFExgBgV6t2K6JtWNb59G9ogdH1MSTws78Ccv2DZRYYp/LYzzKt8Y9
93EdG/2d2vAf9+C/pm7s3iSsL4asAVB0FuRYFn7gIT1CA5ENXrzaVE9SUmjP9VnW
+6HTeen9grqmOdSPDbXE4t2Ew31PQQD8E+oYyJ+yHR5igA/O4e4=
=OlTJ
-----END PGP SIGNATURE-----

--3jK+0sHr6j/jwA0V--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
