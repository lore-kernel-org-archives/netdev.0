From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv2 3/4] rds: ib: add the static type to the function
Date: Sun, 12 Mar 2017 21:34:34 +0200
Message-ID: <20170312193434.GI2079@mtr-leonro.local>
References: <1489306078-3354-1-git-send-email-yanjun.zhu@oracle.com>
 <1489306078-3354-3-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="IvGM3kKqwtniy32b"
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
To: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489306078-3354-3-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--IvGM3kKqwtniy32b
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Mar 12, 2017 at 04:07:57AM -0400, Zhu Yanjun wrote:
> The function rds_ib_map_fmr is used only in the ib_fmr.c
> file. As such, the static type is added to limit it in this file.
>
> Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--IvGM3kKqwtniy32b
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljFosoACgkQ5GN7iDZy
WKeLVg/8D8EMrWmoZcqwmq/d9kWWiJUbd3vK8vpCUdxdzwlfmdsUVPni+cfcs0PA
I4FaQmeosiLh1zd91jFwi0791Z85oa0YUPveHfBVh/c/OiYjZ2ROFqslvtHXA0Ac
bOHwewGc0AXnTuDNxu6555eS/OFZMd2Q7lhNZHec87jGpcpQfz/IqdZu+EPjllK6
3//EqrHkyZwdD+yj8+ISqYH3Lc7yb/XscgeiuyrTbb23otJDKgfhTP4t8wTjfeuM
sFmh694h0EfSZgajei205p/P0hnF1IkC2TQpwfBGuBFCDcCXeDn8I1dpURw06sE7
XyVkRMdyxRbmMl9V+WkzEHwaMrZZaDSzn6gFUZpx4+T5OfbOuVrfRljQhexLR5LH
FehSWWiQv/1fAu2pFIldSbO3LsbPXU0eY8Ca6xybTi8Q7c69bdVtKP/QI6Apzq5H
FYsOpjQVmkVmBQ1W9kNGnDLSuUVgjyjfCpQZ/jazVrCy09GAQ8dkpDQ2JWBY19nK
m4S+NXr7az4WOvdmrniLzSm26qi99zx247qkQgcN9mh9eLOpMN7tEG42xDyDPeCv
g0KHFVDKBzvPnt/hsvXtJdDaX/AagGuzq5i1lAIf+1nkLoJ7uK1tR6fGIvl5f9VP
WK3i8I7t0JFqE75m1AgbsZYW5+TvPZGdpaFA8A6AvbA1ELmzjBc=
=v4iU
-----END PGP SIGNATURE-----

--IvGM3kKqwtniy32b--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
