From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/1] mlx4_en: remove unnecessary returned value
Date: Mon, 24 Jul 2017 09:33:09 +0300
Message-ID: <20170724063309.GL3259@mtr-leonro.local>
References: <1500865373-32411-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="9MdG657QzbOEWl1C"
Cc: tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1500865373-32411-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--9MdG657QzbOEWl1C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jul 23, 2017 at 11:02:53PM -0400, Zhu Yanjun wrote:
> The function mlx4_en_arm_cq always returns zero. So change the
> return type of the function mlx4_en_arm_cq to void.
>
> CC: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> CC: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_cq.c   | 4 +---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
>  2 files changed, 2 insertions(+), 4 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--9MdG657QzbOEWl1C
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAll1lKUACgkQ5GN7iDZy
WKdnqhAAp2IumcqLuegrVGpENH/T3P8NeLiIvd5hMsPiW4v2FZ3I3t8LYCtS5WZ1
Bb4cFyHEXCP/DuuBZKRq1TCWQkkbGgGLLDw+nnHezZvCuOjiZDHTvMc7YHa1tUyK
i8ohl1WSsno+wJ8zyNRUmCqvhLMbNQkvU8Z6bLYS38NwY7KWshZGUlzlfhvGmRT0
vZsdaAf/vITd++LLH/sxVTBRDoPvXGTrfREk8MFp2eS0XYTX5eXqkHqu7jl+oe8j
b23eTO/9av7gJWDMKsTylc/LCZ19TKoozmC4gEcXp7ecN1f3gVW66KLXIM7SDKmj
F0pGa6jiBr1SIyPrJWvEiJRWGPy4ilyA5nsGmZbEjNeYAx+qmjYWQ2rtc+BkwATF
v5sx0MqJKMDVGNjhS9AUtch7jtMPklrPgn7+q8nSGNFlrLRIgMqh8GPYSYkS6Oin
3+pl3LeHWcQNDLudWTkurPMu064zc3fJygcNqs1aviX6BaoIdwRQoOVK/jlnxFYY
I5D/tRYmmKnWgZ5iVmtWusCte6eeSMWdd1Y3pOUsCRMYHP6Rs4XfpHDbV/WmmmKz
f8VBEcTocUaHbK+4w8hhFIuys5TnKFzuZbS/fI/m2aHVI/vogKv1XLr1EcH0PyyO
0uFONF89mKzs2OvGa9JHDHJIEyUIOKKs1wKzqSL63RfKicZEGQY=
=j2xI
-----END PGP SIGNATURE-----

--9MdG657QzbOEWl1C--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
