From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH net-next] net/mlx5e: IPoIB, Fix error handling in
 mlx5_rdma_netdev_alloc()
Date: Wed, 19 Apr 2017 13:11:45 +0300
Message-ID: <20170419101145.GJ14088@mtr-leonro.local>
References: <20170419095914.GB4266@mwanda>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="+ZmrHH5cGjskQnY1"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170419095914.GB4266@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--+ZmrHH5cGjskQnY1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 19, 2017 at 12:59:15PM +0300, Dan Carpenter wrote:
> The labels were out of order, so it either could result in an Oops or a
> leak.
>
> Fixes: 48935bbb7ae8 ("net/mlx5e: IPoIB, Add netdevice profile skeleton")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>

Thanks,
Acked-by: Leon Romanovsky <leonro@mellanox.com>

--+ZmrHH5cGjskQnY1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlj3N+EACgkQ5GN7iDZy
WKf4aw//funXLakxh4Z2ypf2K50fPDMYg4vJxJyfUbGt8F2Homz3g1oZ28D3jvts
EQxMQpl5BSy5oRNWIUe0Rn6ABJLpLt0hWU5DoM5UDaU2/j0apL7L1D08KP/M2G+A
2XSNlm+t7uJ4EqGaQEoIR7FecWUiLq1JM2uYWZvW4WvYyQjQNA+V2OLI2JAr21aN
c8fQ5TXaootuVSxZsNOrvn5lkmqkxLwwzkp4ICZigm77Stfu37XUby8bsPmcYox5
C5I6FBXdr//2AmNDJ3PXAx9ELopdi4PehnPct5oObbsVuj876OrzM8f6HrEw2S5J
GPR1z2ttRC8zMWMoy9LOzQ/2EqCFlLW0/Y+qQrg2WL7JKIH/BbZpT8nC+d4pyxO8
pk0pCya/9m7y8D344/lwG/VmGLDKgognDszXnmy68AY4vJmddsLQPFgRh4JheZTt
TNjyelx94hK+ljSmRDJIHCv/kaV/urbcU1WLRWO83m9+qhvdGUslXST/xu4Tutx/
zc6gJJx4kjp/HGfMgiY1tzlWwLFgrI19b05cAjiAAdvPdKIdyrZ4ul/KGbOJjgYV
u1nNxVLaRwM6zLvDEzgvO+vjBPVDhoZv4RpU87uDXEJC9zL0Ov0OnQHOHLuCOZRF
e1/kfDMhHhxSAbGQxNf6SwsfkCQw3CrpCAa3FgIRoVjbLBMTAQc=
=nPF6
-----END PGP SIGNATURE-----

--+ZmrHH5cGjskQnY1--
