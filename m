From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 16/16] MAINTAINERS: Update for PVRDMA driver
Date: Mon, 26 Sep 2016 08:56:57 +0300
Message-ID: <20160926055657.GE4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
 <fe5e7704757254073963cd40bff5240421b1fce0.1474759181.git.aditr@vmware.com>
 <20160925073010.GW4088@leon.nu>
 <7ddc5906-6ba8-335e-c0b8-eb60427a1be8@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="gJgGjUUWrnN4mpen"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7ddc5906-6ba8-335e-c0b8-eb60427a1be8@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gJgGjUUWrnN4mpen
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 25, 2016 at 10:22:02PM -0700, Adit Ranadive wrote:
> On Sun, Sep 25 2016 at 10:30:10AM +0300, Leon Romanovsky wrote:
> > On Sat, Sep 24, 2016 at 04:21:40PM -0700, Adit Ranadive wrote:
> > > Add maintainer info for the PVRDMA driver.
> > >
> > > Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
> > > Reviewed-by: George Zhang <georgezhang@vmware.com>
> > > Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
> > > Reviewed-by: Bryan Tan <bryantan@vmware.com>
> > > Signed-off-by: Adit Ranadive <aditr@vmware.com>
> > > ---
> > > Changes v4->v5:
> > >  - Added pvrdma files to common UAPI folder.
> > > ---
> > >  MAINTAINERS | 9 +++++++++
> > >  1 file changed, 9 insertions(+)
> > >
> > > diff --git a/MAINTAINERS b/MAINTAINERS
> > > index 87e23cd..5023dc0 100644
> > > --- a/MAINTAINERS
> > > +++ b/MAINTAINERS
> > > @@ -12615,6 +12615,15 @@ S:	Maintained
> > >  F:	drivers/scsi/vmw_pvscsi.c
> > >  F:	drivers/scsi/vmw_pvscsi.h
> > >
> > > +VMWARE PVRDMA DRIVER
> > > +M:	Adit Ranadive <aditr@vmware.com>
> > > +M:	VMware PV-Drivers <pv-drivers@vmware.com>
> > > +L:	linux-rdma@vger.kernel.org
> > > +S:	Maintained
> > > +F:	drivers/infiniband/hw/pvrdma/
> > > +F:	include/uapi/rdma/pvrdma-abi.h
> > > +F:	include/uapi/rdma/pvrdma-uapi.h
> >
> > Please remove the last two lines, these files will be maintained by
> > Doug.
> >
> > Thanks
> >
>
> Ok. Based on your recent patch series on export vendor specific ABIs,
> the ABI files were added to be maintained [1] by individual driver owners.
> Is that not the case now?

I based my answer on this response from Doug [1], maybe I'm wrong.

[1] http://marc.info/?l=linux-rdma&m=147464894811998&w=2

>
> [1] http://marc.info/?l=linux-rdma&m=147455473718235&w=2

--gJgGjUUWrnN4mpen
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX6LipAAoJEORje4g2clincckP/1fxA2jFABGw1a7XAg7AHLrh
p749jZMLOmA5Yr1IEVtWD7YyTupZEQvkKZBIWhMAJTxhp4mzPhde2ZQ5Yoiky/3u
rfH/wYFhVjO9KmEEFPgOmxyjl7t3Imb5fyTxbfAoXWe4qwOAV4/D5FOBWrd7EeJr
jUE7M59hWArkevTEAOz8lxx7olAtzBa8D+Ik6c22ZTDV/mDfSmdlZrGr7xq2lNqw
CUYLyObuUvsELZoSSfhNV5tt9Uc6YT4lAgGFar0+xoRo3WzR/WKx8Iv9DX2+xbCC
LX4MsOMwqUxzUA7vD1J+tJKlG7Jjfm5WH5DQIx9/HBFOA2grEreY87z5YdQqTjNH
lJ6h5nYA69QwEZwvIgh0CgpOj5lqIzLwzS3GMlCTErylIHSmV99u0MkLXG+LI5gv
A+FDteV+lG1zOL7Xpfe8lolAyGMlykMEGKfXx3L2XwUUjvomCfUUejWzLEP1rgzG
pCYHS2UL3iG74YfOSgzy5/jV3PyAwmFmC2rgdjx+UFipBICEqWCH9rbdXd6L+1Bp
Va3Og52ZNS1MmBtcQbi+uvzultE1J1UdPGahJt3vthzzjh6+gYqhOR8LBzfnE/vu
195lqR1NF07n0uDID8sdmfnsSOwl4FP2mqlaiMVfoJznFjyKgNoHtj8zz755F85M
ALxeYVazTcTP8LHSe0ku
=H3iT
-----END PGP SIGNATURE-----

--gJgGjUUWrnN4mpen--
