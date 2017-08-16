From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH][V2] net/mlx4: fix spelling mistake: "availible" ->
 "available"
Date: Wed, 16 Aug 2017 17:21:34 +0300
Message-ID: <20170816142134.GR24282@mtr-leonro.local>
References: <20170816134250.6689-1-colin.king@canonical.com>
 <20170816135851.GP24282@mtr-leonro.local>
 <fa81af22-0a98-bbda-718d-e069287172fd@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="CXwywHnYJ7GE90zd"
Cc: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <fa81af22-0a98-bbda-718d-e069287172fd-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--CXwywHnYJ7GE90zd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 16, 2017 at 03:02:31PM +0100, Colin Ian King wrote:
> On 16/08/17 14:58, Leon Romanovsky wrote:
> > On Wed, Aug 16, 2017 at 02:42:50PM +0100, Colin King wrote:
> >> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >>
> >> Trivial fix to spelling mistakes in the mlx4 driver.
> >>
> >> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >> ---
> >>  drivers/net/ethernet/mellanox/mlx4/cmd.c    | 16 ++++++++--------
> >>  drivers/net/ethernet/mellanox/mlx4/fw_qos.c |  6 +++---
> >>  drivers/net/ethernet/mellanox/mlx4/fw_qos.h | 10 +++++-----
> >>  3 files changed, 16 insertions(+), 16 deletions(-)
> >>
> >
> > What are the changes between this version and previous one?
> >
> > Thanks
> >
> A fix on "Availible"
>
> -	mlx4_dbg(dev, "Port %d Availible VPPs %d\n", port, availible_vpp);
> +	mlx4_dbg(dev, "Port %d Available VPPs %d\n", port, available_vpp);
>
> Colin
>


Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--CXwywHnYJ7GE90zd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmUVO4ACgkQ5GN7iDZy
WKcKhhAAvfr47rZk/UxrjyT/8/BuYLAtcUR3ecV1YR3NCOeAfL1VLWI/lytsw8Gg
or1H1O/k/vhzLtBlD6u0KHqakUbDizPkGsuqcV/9sdpMkVkYHZbpI9cjV1wLfNq9
tRWDIue7+qeoeF8Kyr91VTWLSE0h0cnXk+LtjfOd9mibXvmYm+TuTMyL3xi/fPuV
/T3lFCP8Y97Di2v3K4iX/Ab3qS1axPaXXy1fpUXm0ecjB0bzgCv1Bqd4lC80HhM2
GzWlLYpxQ9/owAAtjOvjvlZgIYkSzlocJL5m+FDHurFgWE1zxwDLnwTlk8RY8lK1
SpVee1pkGKGQAHGS6JT//8HIYC33e/xz5jIywnHptBatm8FwWAhXVkDjAAN18v1G
ihUo8B1VY4PYOaEJeNVqdr7RBiiWnWzjD/OrsY8ujvpWgPjjiKxOBzZ1MiHDFzzD
Z+yEyqCwfXopAKztEMU9TohG96N2nwbZg+LZY4Tc19z4FoaVesp5PaXYgkbk9Tq/
6ylXCfBgAnBzyAOCCyJfutcaOROxePzLmpvnh5+jSIdqHxfyemPZH6HK2fa+COg/
kUh7WHlIRjwOrqEDat4bJC74S02Ep1RlEVaphbqqGoK23XK+iYivTO9knNAWbxxz
3dvxPOUDvqMmHrjVMN+nkA7qtiLhRqw5o/8HFZl/6xD0N4Kw/OQ=
=imF8
-----END PGP SIGNATURE-----

--CXwywHnYJ7GE90zd--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
