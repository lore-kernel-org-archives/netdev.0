From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 8/9] IB: Convert ib_dma_*_coherent() argument type from
 u64 into dma_addr_t
Date: Thu, 12 Jan 2017 15:12:57 +0200
Message-ID: <20170112131257.GI20392@mtr-leonro.local>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
 <20170111005648.14988-9-bart.vanassche@sandisk.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="uAgJxtfIS94j9H4T"
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
To: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170111005648.14988-9-bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--uAgJxtfIS94j9H4T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 10, 2017 at 04:56:47PM -0800, Bart Van Assche wrote:
> This patch does not change any functionality.
>
> Signed-off-by: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
> ---
>  include/rdma/ib_verbs.h | 11 +++--------
>  net/rds/ib.h            |  6 +++---
>  2 files changed, 6 insertions(+), 11 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--uAgJxtfIS94j9H4T
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh3gNkACgkQ5GN7iDZy
WKfnRRAAr2CAKQHBEHxpkofVg2wUoJHG89XvfM41jPyBigzayhT57/kn1OY9mZav
kbvDWTedd3uaunrzW6NPgFnd6xiAU6FiuT4NnkqHen0e4d4EvmCQrOqxl6GojKSc
5pCYVlmv/LXnRxxW1gDug7QYT8FGtpWQ59DKU3m1+BbqEv0gC7BP/mTmG01Ybk6N
tIj5WJ+WBqK/c7vk77QeKo5xOsmLaU7c5AAt4Crj93Kfh6A7+Es5+JARZftMhH4T
xUiBX9QCT9bVBiHrbFCMZ3qxZlcMedhTc/2DruNKE2FT2S/ywv8nxrTpYumY85u6
ocLrnKDzDhC0k8YotMtU743zyiZO/rSwkxKlI1nBPsXSGIMSFU8u6OnP90sZ1aWf
eTNh7ugyZPJ2PZHAeG6LQh5AuIUNje7Q1dVJLi1oe/83ciGBDYgT8nb2trLm5bDq
YvYfUJug+65GV9CFiXm9/sJ7QySvLDBKuzV7Df4gSd0jf+8tOLn69hSU1w7ybywr
g1fGI4tPyS+ymb79yeHuSiM3S8mka9JQuy5mxJTRK6NZmxtTqwrpr/G84KkDup75
8Yn7uc4NBm0MsYKcPnkzcoodzwCgt1hth9yvDfK5VLjWEL2VFFfCYDM5FbiMqQgH
5wZCfIs2TXOnLFCY1YTIG6D1KHFIoOlKh1t0FP9pkewoC7l7fv8=
=M49R
-----END PGP SIGNATURE-----

--uAgJxtfIS94j9H4T--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
