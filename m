From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 16/16] MAINTAINERS: Update for PVRDMA driver
Date: Sun, 25 Sep 2016 10:30:10 +0300
Message-ID: <20160925073010.GW4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
 <fe5e7704757254073963cd40bff5240421b1fce0.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Wt10+cXOThorkX0z"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:42066 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031643AbcIYHaP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 03:30:15 -0400
Content-Disposition: inline
In-Reply-To: <fe5e7704757254073963cd40bff5240421b1fce0.1474759181.git.aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Wt10+cXOThorkX0z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Sep 24, 2016 at 04:21:40PM -0700, Adit Ranadive wrote:
> Add maintainer info for the PVRDMA driver.
>
> Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
> Reviewed-by: George Zhang <georgezhang@vmware.com>
> Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
> Reviewed-by: Bryan Tan <bryantan@vmware.com>
> Signed-off-by: Adit Ranadive <aditr@vmware.com>
> ---
> Changes v4->v5:
>  - Added pvrdma files to common UAPI folder.
> ---
>  MAINTAINERS | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 87e23cd..5023dc0 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -12615,6 +12615,15 @@ S:	Maintained
>  F:	drivers/scsi/vmw_pvscsi.c
>  F:	drivers/scsi/vmw_pvscsi.h
>
> +VMWARE PVRDMA DRIVER
> +M:	Adit Ranadive <aditr@vmware.com>
> +M:	VMware PV-Drivers <pv-drivers@vmware.com>
> +L:	linux-rdma@vger.kernel.org
> +S:	Maintained
> +F:	drivers/infiniband/hw/pvrdma/
> +F:	include/uapi/rdma/pvrdma-abi.h
> +F:	include/uapi/rdma/pvrdma-uapi.h

Please remove the last two lines, these files will be maintained by
Doug.

Thanks

> +
>  VOLTAGE AND CURRENT REGULATOR FRAMEWORK
>  M:	Liam Girdwood <lgirdwood@gmail.com>
>  M:	Mark Brown <broonie@kernel.org>
> --
> 2.7.4
>

--Wt10+cXOThorkX0z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX530CAAoJEORje4g2clinf0oP/RF5FNKA/DfYok2dkbFKAxaw
7+oRV5wCfy1qdPkiDAdBtpB/mUkgay1DhgPa0vZe1tgCcyIh8O8sFBZQls/pEHOq
AtcLrGGJcYwiP4tWnR4r7+8SEBEkNXx9cOM0mktUbvkBmkgzphHXaEz5gFgfjLH6
VPJP20L9J6CDPJ1R/f7CJvoHy0I18WqyklE/gJ0cSD15+QYbfFRi8eAKE+7gXMVv
Pq37sgaudlwAkxvgi4VwpxmK5fLtRCzcgHVgoWvPThUYmewSRBx/1AqA57FjYOiV
P6a8+WJS00b/RBgdyoUaapEwd3MJLijz0IAPD6waMZysPAIc9LR/HBugera8marD
NSXAKK+nuulCtqn9Ul5jMTlcFlpoa1D73Wq961C/sdwIy+QKz84cLZxVQGHtalcs
nLtr5qhWqOQGiffCMhJ1I7/r0hmGuwvCNOdLUwYKK4gmlNT8p42o2f7QQvyqyY2Y
pH2la/VdGMHcuyutty1LaaO2mkacyp3iC8enHu9qy7LyPqe3W+XwxJ8tdlcEKBuT
6N9piDRjt5ToVYqBsyh6Y093yk0DwD/PWptAylpFRPvFwGYXld9ttrlOxiBoBNSV
c6iRczm/zig1MyavZFJRPSAeyT1t9It968fcsMshTs7Hic8/IAyDliDUOyBhGsru
OmeTtEJB20XuL1+jSevS
=JWJF
-----END PGP SIGNATURE-----

--Wt10+cXOThorkX0z--
