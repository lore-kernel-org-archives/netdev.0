From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [for-next 07/10] IB/mlx5: Use blue flame register allocator in
 mlx5_ib
Date: Tue, 24 Jan 2017 11:44:31 -0500
Message-ID: <1485276271.43764.31.camel@redhat.com>
References: <CAL3tnx4H2HsGMH=caiobivvvs0AU9yrzCmVONOdUQ_j_JMfufA@mail.gmail.com>
         <20170105.150731.2097384465565543422.davem@davemloft.net>
         <20170106060608.GG15685@mtr-leonro.local>
         <20170106.111131.1775665484264248231.davem@redhat.com>
         <20170108062257.GH15685@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-XQskfkDTWhQ+vYH6koF1"
Cc: eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170108062257.GH15685-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-XQskfkDTWhQ+vYH6koF1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2017-01-08 at 08:22 +0200, Leon Romanovsky wrote:
> On Fri, Jan 06, 2017 at 11:11:31AM -0500, David Miller wrote:
> >=20
> > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > Date: Fri, 6 Jan 2017 08:06:09 +0200
> >=20
> > >=20
> > > On Thu, Jan 05, 2017 at 03:07:31PM -0500, David Miller wrote:
> > > >=20
> > > > From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
> > > > Date: Thu, 5 Jan 2017 14:03:18 -0600
> > > >=20
> > > > >=20
> > > > > If necessary I can make sure it builds on 32 bits as well.
> > > >=20
> > > > Please do.
> > >=20
> > > Dave,
> > >=20
> > > I'm failing to understand the benefits of building mlx5 on 32
> > > bits, and
> > > see only disadvantages:
> > > =C2=A0* It is actual dead code without test coverage.
> > > =C2=A0* It misleads reviewers/customers by seeing code for 32 bits.
> > > =C2=A0* It adds compilation time for 32 bits platforms and "punishes"
> > > them
> > > =C2=A0=C2=A0=C2=A0for not relevant for them driver.
> > >=20
> > > Why do you call removing all that as a "regression"?
> >=20
> > We have this thing called "CONFIG_COMPILE_TEST", it has tons of
> > value,
> > perhaps you've seen it before?
>=20
> Thanks David,
> I see your point.

What's the status update on this. =C2=A0Unless I'm missing it in my rdma
mailing list (which is always possible if I scan subjects too fast), I
don't see a v2 of this pull request, but I also don't see that David's
concerns have been addressed, nor that he has pulled this.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-XQskfkDTWhQ+vYH6koF1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYh4RvAAoJELgmozMOVy/d3/sP/00NcMsP8sGm7YL/NfMFqr83
I9PRC+iz2zbYrJ6ijvtU78Z7RxGiV0t5WfV+ag1P+8U3WUPUm/kpaYECUUX1/ws2
AgNeeijvjF8fjd2SQp0d9zL58WDokKo/wwSbnedIWX55YFVLa9HZbp/hzHBCpiNz
AzgbL/Co9+9Q4yeh04372esSMCOw1qayL1F9rG9ACZQjLZNtl6M8OcOoAkJExtPm
TQUir3bGUmevPY/07+3humzrfBZShuO+mHwHamMIcldhRjzOopAbifxomhQERlEq
H80+EuxWazjjIKn+zANr1qa+kDm8Zg1Lm6Zd75nvyLACytudNT1eyEK5YaCOykcw
c8fB0oEPBkz/pdJfCVJICqmgKBDSogZjB3/bvIt0eTsapBdxNQiAfFWp3uPGoaPl
42pZEGfC4S8O8AMkgj3A5rVhFseB19/XQo54+dC/QtHFZulrn4Z6xnoUsIB+Sv+1
3l0QmafYgZE6TlRnNsDK5g4C60P7gRocHfYXIjrpAmL3uIyB2doOheScHjaMiCGe
A0+cG0Y5JMILwROzpDTM6+yuF5C0iBZ7k0qOx9m7BjzzlM3TMS3awwdxy85ah3OD
S3KovwWbGauH0GjmIf3SKymJnKhDkPN4r8euNsPsBR1tHc90+UHBsfvZd9N2qzUu
tfWp4pKuexAMlJjmr9wL
=YxHf
-----END PGP SIGNATURE-----

--=-XQskfkDTWhQ+vYH6koF1--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
