From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 1/1] mlx4_en: make mlx4_log_num_mgm_entry_size static
Date: Mon, 3 Jul 2017 09:52:35 +0300
Message-ID: <20170703065235.GF8041@mtr-leonro.local>
References: <1499060119-7063-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Zi0sgQQBxRFxMTsj"
Cc: tariqt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, yuval.shaia@oracle.com
To: Zhu Yanjun <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60860 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752198AbdGCGwj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:52:39 -0400
Content-Disposition: inline
In-Reply-To: <1499060119-7063-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Zi0sgQQBxRFxMTsj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 03, 2017 at 01:35:19AM -0400, Zhu Yanjun wrote:
> The variable mlx4_log_num_mgm_entry_size is only called in main.c.
>
> CC: Joe Jin <joe.jin@oracle.com>
> CC: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 2 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h | 1 -
>  2 files changed, 1 insertion(+), 2 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--Zi0sgQQBxRFxMTsj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllZ6bMACgkQ5GN7iDZy
WKdcwBAAoB9CN9KrkcvS6HIJodsA/+yl6hRTK7H1GxbDMpZgmgsF6rrRP6XGkx5k
Slm0upiwlJ/ve9gnTB0O4NuZRrwdD0s0ucljkcwgklYJD5ZC+6q+qI7Vl4OelkRD
QGe+ViNHhELmd56EIJ9YejfN+Y34lV3gm3Ivl+GhGfBrMHoyqOILA5rt7fze9oiS
ZIINRbIIsXr6EDlUTl5geLMYWkMEAEN/XeVREEDAX/o704RpCDpyCcoKiKRKp38S
GuWwbKOxKQAkbvjeSOAvhiyHs/PhQ3FSlE26mbsjFuX4DpQh8l2s2Y0COQDbn1j8
CEF9Ypked6xcZczZgUx1QuwuETAHEShm8S90cXKA/o2GbZh31BOh1qj8KAEwy04K
tRG5Mz/ZWymAirsW78gN6rvK5l4IgrH8ylfy67yjGuxMW/8X93cMBqhZ9hgtMgnR
5Y/9PFbz82OmN9I95J1hhsASniO0tGt33DQrERGNg9KyNDcZh/PvaGO+QOfbu8Zt
9gDE6t/9Blon92S9KTFZMkQig8a4on9sXfeV2+kox/13WXYzenpztEYGrIWfXHWu
vhsoszvLvkkq8BCTA/8leieijMUYLDB+AxvGnup01pasSkgouqLpz1hV73oVirjl
PE8EdSs9Eqh2vEY3LDjV4Cvq4Nm+bbHDsZjGgqBbSZXVJlwQUAo=
=Rzpx
-----END PGP SIGNATURE-----

--Zi0sgQQBxRFxMTsj--
