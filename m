From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v6 05/15] mlx4: Replace PCI pool old API
Date: Mon, 20 Mar 2017 08:32:25 +0200
Message-ID: <20170320063225.GU2079@mtr-leonro.local>
References: <20170319170404.17362-1-romain.perier@collabora.com>
 <20170319170404.17362-6-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="wXC5D88JtmMokAwr"
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:42960 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751153AbdCTGcP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 02:32:15 -0400
Content-Disposition: inline
In-Reply-To: <20170319170404.17362-6-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--wXC5D88JtmMokAwr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Mar 19, 2017 at 06:03:54PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commit replaces the PCI pool old
> API by the appropriate function with the DMA pool API.
>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c  | 10 +++++-----
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h |  2 +-
>  2 files changed, 6 insertions(+), 6 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--wXC5D88JtmMokAwr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljPd3kACgkQ5GN7iDZy
WKfZZg/+K+epYpX1CvaCLm/lxsWyO8WW7eqjUmJNCTRJf1kFxDMoMW/EA1sPddCo
P3flV+e/0Pu18xmTwnWQ77FeRc2vd/PhqgISWadPJQRMXl8CiEOuUxR+b6frYgxC
h6IFB3oT2AJsqpsAOkV53GOPCPfoK4dfHiiv4gu5JSttUwzIz24qxIceFhEfu/I8
t1gX04fWAGRwD01qK8zSkA4l4vZ6P5QGJqYzvXXkOJd8RTyxvV+hnVeFeHTriWVM
PAUveAzvgJp+faCf1pzqRIx+4dVezYlBlYKo8bvwo50YaA4JoEWWSMxdiaS7IyGN
7ltW34hF8eLCHVjSoQCvud5kB0XRf07oqocntBzcIloYKjgW+MItc8rf8bqQzcTb
xl+uBn3oY1hBQ2GfyhEjmlWUUA80tJy6tdl9nXN1L/LMU0J9mrgu9cJdizURvT+a
QYcdG5rXBZghA0x5V/FBFbniskL/iL6bNZ6ENtrMLzt9Iobd3nRpRZbjxfthUjHk
Nn57b6rHf4wmEVWGAfOQkNCDX3LiK6DhHQhVx3tT0jhWr0b6wcjCzuR6g8wZN8V0
c+Z0DBynAO3eJXGg7K35KHPmB48s+FHBTABc86gJrkZaOaWxOGlqwCTrDKa4v/Hu
6ODT8nnUrLeoI7S+J0J+3+HiUHdpTkOS4T8Wn7gdEF3c2gT9jk8=
=zawc
-----END PGP SIGNATURE-----

--wXC5D88JtmMokAwr--
