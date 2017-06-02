From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v6 00/21] net-next: stmmac: add dwmac-sun8i ethernet
 driver
Date: Sat, 3 Jun 2017 00:24:22 +0200
Message-ID: <20170602222422.2elv6snjp3ahrhbi@flea.lan>
References: <20170601.145819.789604139072328057.davem@davemloft.net>
 <20170602063752.aqyvwcykvepiyt4y@flea.lan>
 <20170602091320.lyfxsanxrypfpozb@flea.lan>
 <20170602.102205.701672574727845689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="neetgydbd5y2azxl"
Cc: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170602.102205.701672574727845689.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--neetgydbd5y2azxl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Jun 02, 2017 at 10:22:05AM -0400, David Miller wrote:
> From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> Date: Fri, 2 Jun 2017 11:13:20 +0200
>=20
> > On Fri, Jun 02, 2017 at 08:37:52AM +0200, Maxime Ripard wrote:
> >> On Thu, Jun 01, 2017 at 02:58:19PM -0400, David Miller wrote:
> >> > From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> > Date: Wed, 31 May 2017 09:18:31 +0200
> >> >=20
> >> > > This patch series add the driver for dwmac-sun8i which handle the =
Ethernet MAC
> >> > > present on Allwinner H3/H5/A83T/A64 SoCs.
> >> >=20
> >> > Series applied, but wow that's a lot of DT file changes :-(
> >>=20
> >> The DT patches should not go through your tree, but arm-soc, so I
> >> guess this is not an issue for you?
> >=20
> > Ok, so I saw that you actually merged them. Can you revert or drop
> > that merge for the DT part?
> >=20
> > This will generate a lot of conflicts with our tree, and I'm not sure
> > this would be efficient to make you take all the entirely unrelated to
> > next patches.
>=20
> Please tell me which specific changes to revert.
>=20
> Thank you.

Ideally everything from 2c0cba482e79 ("arm: sun8i: sunxi-h3-h5: Add dt
node for the syscon control module") to 2428fd0fe550 ("arm64:
defconfig: Enable dwmac-sun8i driver on defconfig")

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--neetgydbd5y2azxl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZMeWWAAoJEBx+YmzsjxAgmv8P/3wb0imU/NQ8m7Gzir2ekey/
p1B29JLWusZxEKMhZPMLRQnRGJJ5sHZ39jx0I+5g/nd6IHMJUeCeHgJ7WopqCdFg
eKjmJohZuAgUesby3nxEwWIM6/mQSoVoqq9p4VHJLTsXTVvCKlaE/5mxLfM+Nc9t
wqjBu2BXPu6pSJjcoYDsAf2znyzVq3QhUulpT6I18pFh2yLs3Wsm3J6rhRLwDYXm
Y8Nwdfu9LRb2vrAZr/nEPXsAmO7FZK1wJ+pgA6X+kNRgeHgPdAEvllayRDnjjFBD
+2JCgjdwk84pJG6L0yqAoUp/Y964sLAg+wxl+D9o8B0oxOL8D15CCkZ9/W2mBXFq
/NeN8rbSbnUdyiKPxTsuLkNoqrADyGb7fk6BSr4uKI5o+HwDWQfw9eFt/bClu67q
0mp2dxkyeFyHzW/Z3ug0JxbaQq2IOZM9ATl32cM3duND+XEvXv/LdYYnDJaRl144
my+2GlPUtNb04P/9IdPz80ckwZvvPUsBgngjpBNGflw8gWdVS9zZ8NYIvQkKi0m1
fo9LBWQvr8ulOuFz3EHvmq0DjSYlvbKj/q+nz03/aKUT56nFQ7TT0C0IoSnjTj2I
h03Ed9eVuY2QK9WsmMI1SWa6SYsW7XWjceCCyoJ37y/ArXsEUMVk4yDQXh7VOZtp
KroazDV0JsPEuvQJAijw
=D061
-----END PGP SIGNATURE-----

--neetgydbd5y2azxl--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
