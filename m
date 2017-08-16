From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] net/mlx4: fix spelling mistake: "availible" ->
 "available"
Date: Wed, 16 Aug 2017 13:01:18 +0300
Message-ID: <20170816100118.GK24282@mtr-leonro.local>
References: <20170816090511.10463-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="jwSnfOBD38i7UC9C"
Cc: Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170816090511.10463-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jwSnfOBD38i7UC9C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 16, 2017 at 10:05:11AM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> Trivial fix to spelling mistakes in the mlx4 driver
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c    | 16 ++++++++--------
>  drivers/net/ethernet/mellanox/mlx4/fw_qos.c |  6 +++---
>  drivers/net/ethernet/mellanox/mlx4/fw_qos.h | 10 +++++-----
>  3 files changed, 16 insertions(+), 16 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--jwSnfOBD38i7UC9C
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmUF+0ACgkQ5GN7iDZy
WKe6axAAotLS+gQEwh2e8LqnUrX+A+gsY3m3+YRFDh6wek/D5PyGTd6Cv+thFLGl
ye4OKiNvlClCLp0zooeWaZEq9SP8uSh/lXRG2t0xR76PO/3ILijKdWq8RF/emLWJ
E5ijC7G2K2Jir7AOW6o8iyM5M1P6zay93EV+H8SJ3RG/AtrYIDoUFcbcedcHgB/g
WHX/YbtpucSHAehdfTXJUznhigM4W9hKnYUA7K096JqTjcKoYP1UVX+xJoDn+fEi
G8Ciy6WZvAeNbLBo/e/hs+O3d6wkpzUPkJloHloXHV25970IwtziHVnBT7ICsSlB
+i37Cw7Mv1flg77NAJ5eE5B9DljoH2njcPS4zRNzSt+a8C/Hy/fltbmCeH2R25SB
rwnTtGIHqJ6Ux08AXJFeVSbAIN8ADv3fK/FimA279AnIKsfUB/fZOXr1ZeZ5zhHf
uU0N0o6GgBs72gYODcRgabZlNqaVXvExHwoUfSIbMxj6bKGsprlAM0uipsxONs4O
6CnGyr//aCWoA1D/AfuZBnq3HHvIRcHBj7/UBq8pcDSrSOPKeHrDD0OH5dwEHMsK
NqgPzcPWIXjFDZqK3hEGrOa9Vs/BnXk3fpMEruaZMCOOkKod5NGvAbU8YtTSHwXH
IFOmf4kdsz1iZuV5kUamXBVOFPx0VNXcQ0+OfL0ZxtDDy2/0AS8=
=TNS1
-----END PGP SIGNATURE-----

--jwSnfOBD38i7UC9C--
