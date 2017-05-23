From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v9 06/15] mlx5: Replace PCI pool old API
Date: Tue, 23 May 2017 12:28:53 +0300
Message-ID: <20170523092853.GL17751@mtr-leonro.local>
References: <20170522164907.22915-1-romain.perier@collabora.com>
 <20170522164907.22915-7-romain.perier@collabora.com>
 <20170523072743.GJ17751@mtr-leonro.local>
 <18745ec7-020a-a3d2-3e50-6a2405baaac2@collabora.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="EVh9lyqKgK19OcEf"
Cc: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <18745ec7-020a-a3d2-3e50-6a2405baaac2-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--EVh9lyqKgK19OcEf
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 23, 2017 at 10:53:36AM +0200, Romain Perier wrote:
> Hello,
>
>
> Le 23/05/2017 =E0 09:27, Leon Romanovsky a =E9crit :
> > On Mon, May 22, 2017 at 06:48:58PM +0200, Romain Perier wrote:
> >> The PCI pool API is deprecated. This commit replaces the PCI pool old
> >> API by the appropriate function with the DMA pool API.
> >>
> >> Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> >> Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> >> Acked-by: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> Tested-by: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> ---
> >>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
> >>  include/linux/mlx5/driver.h                   |  2 +-
> >>  2 files changed, 7 insertions(+), 6 deletions(-)
> >>
> > Who is supposed to merge this patch series?
> >
> > Acked-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Each maintainer of the corresponding subsystem, can take a patch, I
> guess. No ?

I wonder if they know that.

Dave,

Do you want us to resubmit mlx4/mlx5 patches as part of our general series,
or do you prefer to grab them from this patch series?

Thanks


>
> Romain

--EVh9lyqKgK19OcEf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkkANUACgkQ5GN7iDZy
WKdBSQ//akrEhgcSBBwwAKW/zMdcOs98lhPxnXXfTQBlOhDHlDtJXh/lGwHjP+/9
kr0UjoTcv5y01F+CnLBwV3kJHvcPf8HAQ+QID29hNH9RmY7/0vNJ92MXyFWkeaJM
o1oNMdnrDDdD5N/CYT0Bb9VMYpMeEcU6trs3G9cQkZ+58K13br3HO0z/JORmfrjq
G59y64WJbS4XM48dD9xu9DfQY2Z2G57JmVk5luHw6Nef9OShd1tcjd0aBTWNLevH
MVCUujcaBqLBvWuc79niFq8vMVzIg8jkeKQKxKOM6yzS0IEcudN3SYuLgVqiKd8A
DqD/GHWfp1oUUzwin2BgrDsftdc35VsvtQrtgs8gHKoTY8g+X+7435tqy+zo2/QS
Xrdo09S+YyDYAO5Ycvz2jWN54y55Qek0P+LtDFCUHW7IUK9RBtlAGceQrFEXkz4L
gjudNrtD636SgfibSO/ExWHgahiwuCRaGOBIitJ1dp1EJsMcyHslzix1GtthX6ts
1TnqzM5uzqVd0PAyZgkij8GV3UhK60acDhE5LnemKJozjjcVYtFW5OL3dPqJ5rVh
r5ohPz+x2O70A2Tk47UepqZ/557jlH11evUZPIh8hzfy/5zpZf2YenG7PU2dzdo8
TO0jDjdI/BGqwe2DPLyY2nARvH7myhRR2d/ELbVsd7lM6HG+4eA=
=ncEe
-----END PGP SIGNATURE-----

--EVh9lyqKgK19OcEf--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
