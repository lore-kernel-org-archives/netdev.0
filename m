From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v6 06/15] mlx5: Replace PCI pool old API
Date: Mon, 20 Mar 2017 08:31:09 +0200
Message-ID: <20170320063109.GT2079@mtr-leonro.local>
References: <20170319170404.17362-1-romain.perier@collabora.com>
 <20170319170404.17362-7-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="peRj85VDUce1fu/0"
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170319170404.17362-7-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--peRj85VDUce1fu/0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Mar 19, 2017 at 06:03:55PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commit replaces the PCI pool old
> API by the appropriate function with the DMA pool API.
>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
>  include/linux/mlx5/driver.h                   |  2 +-
>  2 files changed, 7 insertions(+), 6 deletions(-)
>

Thanks,
Acked-by: Leon Romanovsky <leonro@mellanox.com>

--peRj85VDUce1fu/0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljPdy0ACgkQ5GN7iDZy
WKc7PxAAxvvR6hINJAkQu/B9aGA/bGBFZ4DzxFApyaGMSz7HBcqwl4SWdhXLFTX6
QztH4XHNdTD9N9TtLoU2hcFASucanTw1fyS5Pesn6FdfdCEYRtCNgpRlTfkdBfGD
Ko2E3IQFFG0tolBW0na0daDTqruRWtQt5GY582HWocAywrpyEzsiIpMxKggZ4u8c
U6X7fyki7VqqOH11maxjPBnXIafAZg09HPpgPhhrXbBmLwlDxTR6DZjEjkm8ej6X
KXONdZjCWq9dAESB2VeKEwD9eNcHEp7rEo0WoymVTLtjoe7nyD7/vA9183BUgT8n
QSu/YqcgJEYCv/eOMZf4uJOqab9fCuLEbmbXbYRdKxgkqvaqZe2Upo6Q9PEUgr+w
GL0Jm97UZAYn0xJ8DWeK6NTFhgsbIZ4nL6t8VUwZii5LFz5Htz0tzqPpplTjNTtz
aQGhZikTB7b5O4G/sYRzD+/Msym2jQbHqTa/9rFtXYVcZb8h9yhcmoH9egewsxZN
kXl2f7AVR132LG9Gvrq4eEi2nJzNBbIt0uNaq+CcP2C+UyzRVwb0Z0zr+1H/Simp
OZWxy4G8uAjW4fKi6tKGgf5mwZGWc725McxB6MCLKYLK3bq26Y2JMIwZJ3UvJ6Dk
mwTRwJvAWUbq3tAqwsQmzbF+oTea2dQexR5FBHd5SMDSElgHjKM=
=b1Gs
-----END PGP SIGNATURE-----

--peRj85VDUce1fu/0--
