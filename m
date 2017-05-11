From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2] net/mlx4_core: Use min_t instead of if for consistency
Date: Thu, 11 May 2017 13:42:19 +0300
Message-ID: <20170511104219.GE3616@mtr-leonro.local>
References: <1494498962-16852-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="d8Lz2Tf5e5STOWUP"
Cc: yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494498962-16852-1-git-send-email-yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--d8Lz2Tf5e5STOWUP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 11, 2017 at 01:36:02PM +0300, Yuval Shaia wrote:
> Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> v0 -> v1:
> 	* s/"min_t("/"min_t(int"
> v1 -> v2:
> 	* Use min3 instead of min_t twice
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--d8Lz2Tf5e5STOWUP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkUQAsACgkQ5GN7iDZy
WKd0yg//SiMHLU9snoPL8CFFmgRP5qU4e3Bi86VsRNWRmx7Rosh1Am1zVgIL6PUH
mfUR5N9S4hjHGEd1VPhgXzQxjacAJC2aFjJFNP7wlAtjyTb0bB4Wl1TGrP/aflYO
G6zQoRXyJ9viej0CQGX1DgVIyL82QlBQiB9njs7vAIKqqpZFSrYSX0LSFV05WJEM
d4f1mbJfVpZZtcLVF+j7UMTZ3QElfgGotAQ9i2vQNM49yxD4IF/y1HNpV7Ny/C+c
PNjg0VsRUTGYkGuI7iYEFghhoJgn4Xj93FAsk/sVRZbWOn2CQlVl0loThqcH3j6Y
Qa+mXI4SThD6zCMC2po3V/nUG2yfYWe2YJpKWznKKRKPmPzFv1KC4ZI96crQDySo
b8GB4hivvKgMBAnsK8w7F5zZl829Ic/esUFc7srwq4PWELnwooWRboS8gJ14ImJQ
BFzzHCcUETJmxAY3329zi4jRFEFJ6fsrRVJmgFWOFkMsifR26MkoIghM9lVGD/qq
k50YqrsBNd6Nzs8r+H31P6EDuRI7zEV8Jb/HTU9nXMdfvXE6Ha4z0yVgOzYrw1ao
YeJrpHZqGe4O3NWwJZX7afNZzUmBnMpy8UMYbF4lNLVEOqbrAJl/szjFjaf4c2nb
SpzF6E+0eQAsnFyfWqn0s1f2C/gDmTJuenr8PLf7s64i3HnqJjw=
=V4j4
-----END PGP SIGNATURE-----

--d8Lz2Tf5e5STOWUP--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
