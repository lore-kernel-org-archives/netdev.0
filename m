From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: merge conflict between rdma-next and net-next
Date: Thu, 19 Oct 2017 09:24:20 +0300
Message-ID: <20171019062420.GX2106@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="jBGnWEXsPC4kSclK"
Cc: RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--jBGnWEXsPC4kSclK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Doug and Dave,

In the absence of linux-next, I want to warn you that there is a trivial
merge conflict between rdma-next and net-next in drivers/net/ethernet/mellanox/mlx4/catas.c

The origin of the merge conflict is the following patch https://patchwork.kernel.org/patch/9986131/
applied to rdma-next. It is part of tree-wide conversion to timer_setup() interface.

Thanks

--jBGnWEXsPC4kSclK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnoRRQACgkQ5GN7iDZy
WKeNNQ//SzAqQXIrvSBogGA3evsnBnW2VXId397W1c4PlTXL7Oc5Tlg1ZZOuxSe2
xq/yk9eIbCIyi2+5ngIXWQgHS1OlRvOnWIMIEzceDJFCwhkgHI2tybcEGkcq6nVe
Zzw6W70E0wGkDx6CwUBZf7FaBxd0sQ2nwJFmT+CkMaivF3eXA7v7NCxqjeqvU9Sg
iXO484ABmXzG2OY4T0DJlvo6yeLeyWHZ9uNu01TdGBQTzoeSfySm8gjqzgtD6bMQ
K272uVNnd9Cn1ho4P2wxBv99Icrxoh0VC6DNHYPm9zJ/oC6lHJ8TCbi3oBn2F/o3
yeZuQL+jCw7uO2ghXrzTa+577mPNy606ePUazZVpgMBK6A1291WLB3hw9AmTk6NI
Zi2WQi2NhhcX1YkNAHWEaA2EJxdhgm1hViCqfVtyxYfzXiGtvoRZDdiy4C1pZEpN
CenGl+XVRQtLvLUDjOf5tWkz8VW+y8KE/5a5UXBMG1ARYTjLQBGPj1FAQZ/rH5tm
dtzQ3p/vvBnQ3JGR1X+Ysg3sdc4us9BfgoqJTahDjwZ/BvbKRUoYU/JtiIyOVNYd
OexR5919SXATZksuQb9gMqGzdlUv5qGh3fIN7fZ9YAKSZ53xks7LE7ivFqtZfrsk
twHGnfVd4x7uDPhbcHpFddHTEGxkZOp2/UTSmNcokeRaLgIci4w=
=wUux
-----END PGP SIGNATURE-----

--jBGnWEXsPC4kSclK--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
