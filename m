From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 11:12:26 +0200
Message-ID: <20161215091226.GC811@mtr-leonro.local>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="TiqCXmo5T1hvSQQg"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--TiqCXmo5T1hvSQQg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 14, 2016 at 11:59:32PM -0800, Vishwanathapura, Niranjana wrote:
> Thanks Jason for the valuable feedback.
> Here is the revised HFI VNIC patch series.
>
> ChangeLog:
> =========
> v1 => v2:
> a) Removed hfi_vnic bus, instead make hfi_vnic driver an 'ib client',
>    as per feedback from Jason Gunthorpe.
> b) Interface changes, data structure changes and variable name changes
>    associated with (a).
> c) Add hfi_ibdev abstraction to provide VNIC control operations to
>    hfi_vnic client.
> d) Minor fixes
> e) Moved hfi_vnic driver from .../sw/intel/vnic/hfi_vnic to
>    .../sw/intel/hfi_vnic.

To put it into proportion, Jason asked you to do different thing.
http://marc.info/?l=linux-rdma&m=147977108302151&w=2
http://marc.info/?l=linux-rdma&m=148000415401842&w=2

And Christoph,
http://marc.info/?l=linux-rdma&m=147985587425861&w=2

--TiqCXmo5T1hvSQQg
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhSXnoACgkQ5GN7iDZy
WKf32BAAoisnxiUHw34RpOwL0zSRD2sL3kN9VpscwUbu2l6rVhCrefLwXhJJX5s9
MWZb1c6Rs+ap/e9tV+yk6DF3uYLAMMUGs39sxmQ9Cp5c09kVP52jUqm1eWWKLe9h
OVZjTPRAJ7VcjabI4CpWYrgcheAcq6wwZKCZ238vISMbQX/8emCkLIjyAqlVQd9D
SsIOQjc8sOjflkKgP+6Tnd8upBNv8a+hifz07ccsLrBoDOXp2aAQ2WtmbuOA8XgH
Xu7UZohp412QvsmCFk7yguWVoVfBWE3MFKxxR5vQ157yRSsvw+MIaWYAFndT2fPQ
qTHeVGYlpcyI1A1oi6PXDPywhuWohisjclwbRzvq/UkppCatm4AJXYe18TcrXUea
WKiYTktfaaP//73i5O8fssG2qIhF/m3YV/q7RsOq3CjLYicIpmuDbB0db4Rnr+qS
OJrcO/xXx0FG00+hHhJXA/lCVqvZv3eu5aj1Dn2bDe+E+BEyxY03OZc6PimrsJxp
N38ZyC5YAfEtQMMulqnKVdtgvS943i3yHKy+OawEH+H3fh6GucBLtefQhJ5NRPHG
t/M7Qny0SdtiO22E4nFAgfIDIKGbqDHhSeoCK01IIvV2vGGPiXrbJVn7Vgxh/Cwd
iG2k6Ap+KX1eF353LzD8YqXH4KOeULDaDgITs4pvM+AA6+laWNk=
=jzLj
-----END PGP SIGNATURE-----

--TiqCXmo5T1hvSQQg--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
