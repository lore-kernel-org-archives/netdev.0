From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [next PATCH 00/11] ixgbe: Add support for writable pages and
 build_skb
Date: Fri, 06 Jan 2017 17:12:04 -0800
Message-ID: <1483751524.25700.86.camel@intel.com>
References: <20170106155448.1501.31298.stgit@localhost.localdomain>
         <20170106.164116.1871412141301427533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-wM1FGzNGpNJjthu8fonK"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:51424 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936656AbdAGBMF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 20:12:05 -0500
In-Reply-To: <20170106.164116.1871412141301427533.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wM1FGzNGpNJjthu8fonK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-01-06 at 16:41 -0500, David Miller wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Fri, 06 Jan 2017 08:06:16 -0800
>=20
> > The testing matrix for all of these patches is going to be pretty
> > extensive.=C2=A0 Basically we want to test these patches on as many
> > platforms
> > and architectures as possible with as many features being toggled as
> > possible including RSC, FCoE, SR-IOV, and Jumbo Frames all while
> > receiving
> > traffic.
>=20
> Overall looks very nice to me.
>=20
> I am assuming that I will get a formal submission once the necessary
> amount of testing is performed.

Yes, your assumption is correct. :-)
--=-wM1FGzNGpNJjthu8fonK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYcEBkAAoJEOVv75VaS+3OuW0P/2rR0zPPlyPlw7wKPxEGsNS5
zg8gvb453vase7mZxzsVzluAqx893AvYVSinlI3eiA4qrqQwBdhaleLIf76fIu/G
+XlK7RuSarCiIA1hw3TJpfkmQlh564bwwuGXRog7J208/bs7nw0ellx5ouGunQKT
jSRRXdwcMfF7t+WlKEPldaxDgJzyjVEwvDVRWJzow17TYmPde3NNWCmEimnbVBq5
ta7atY8CPTxOOlrEhepaOwTbnb2HpJgNFlDkD2zzZjlUnGuGe8YWGjWlZtj5X+yf
e4JGKG9IlAzag0tkL05yHKhq4p2ioEsxiq8UFxSvWpc7JNvEfxzWJncVHVgph6OT
YAMYDifFQMVKrSuVqR29/RQsHBrKUGd6McgkTlWbWy8Ru/VJtOOovBWGkTUwUUvh
7hBzNQNGuV+SjSPAN3ue2DEixqRm0VnQIHYlMR/6+BjJw9ZssFb6UY+BhyhMJD1l
O/J3Spuk36GDzMoZttuxVlmA1BENbrVQOjqeiffswHWG7d2zQapr3VJki+hkOsm8
JvwdNw48DKw3+9VyK16U3gz3JRkCWWBZ/Iisdio0ZCLPGerDC2n3bR3tS6f6EnfD
C6DTbMvY+1ENsfvLbAhbON+NlJUQNoKyNdJ5oCEr1xILKuxNgRTog5E2YkbvLttN
BD3S8pgJT00p0Mwagn0R
=Kn44
-----END PGP SIGNATURE-----

--=-wM1FGzNGpNJjthu8fonK--
