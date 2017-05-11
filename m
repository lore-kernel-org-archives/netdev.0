From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3] net/mlx4_core: Use min3 to select number of MSI-X
 vectors
Date: Thu, 11 May 2017 13:48:43 +0300
Message-ID: <20170511104843.GF3616@mtr-leonro.local>
References: <1494499258-17017-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="B0nZA57HJSoPbsHY"
Cc: yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494499258-17017-1-git-send-email-yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--B0nZA57HJSoPbsHY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 11, 2017 at 01:40:58PM +0300, Yuval Shaia wrote:
> Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> v0 -> v1:
> 	* s/"min_t("/"min_t(int"
> v1 -> v2:
> 	* Use min3 instead of min_t twice
> v2 -> v3:
> 	* Change commit log header message to reflect the changes made in
> 	  v2
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--B0nZA57HJSoPbsHY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkUQYsACgkQ5GN7iDZy
WKfh1g/+LvrbCfgEwEuvAEHjM6ENHoXhfksOpgF/NQfbdbUXPmlbvTmlnH7yQDws
wkMeHjADdzE3WnXZSa8pZZH61iDRRTooioM6MKDgAhU1R5COaRkh5vdOLyJm/zxy
BZCBZP1xKhryB+FigkIO3uWM8EWZDlFDZp8oA3mPDgX6iJ5jUk5F2V4Gb4nGeiES
NOvN5Zoenu2vcf6cvz0Z6JG5HMTW7phm3dvvYMsNsPqtHGfdJnQLGsaIpjyiXmdg
XGzCoaUCwpntyWR3RJkNxLOCqDuEy3fOM8OaJDx/2SIqRHX+TCMHFfy3GGu/7TZq
70/oRtEpZo/6acY04JfuTsE2EH61P9jeisV4ZcuIPpIVRsBfB4Ph5G3E4+C4iCrW
hYbvfCxMut/7TdZHHqlLiqQG+DXCpraRGbxW6V+n4H5oRgc6u1rpMXX1QvFl+ZZf
WiGXAQmTwsD4LPvuk2YqmsXnRz5qkDfqAW6i5KKfHajdHibUWvWC5vBhOQUssA8N
mjr1OdgIZ3C8ipISminp2cz0rAUl8aGjGnmxORdpsNgCT6Q7ypxBXDw0E3kqleKL
5GxaY8eLJXVepZRuKUVJy4YBY7ZwtU1A0EROhrjXjFjJXDynwAEsLZmYbTxGvaCw
335tT0PlVBfezhSKK+ZASt7EUMuaaU/GDbjHhoqyNnzBgg2dVlg=
=o1Sy
-----END PGP SIGNATURE-----

--B0nZA57HJSoPbsHY--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
