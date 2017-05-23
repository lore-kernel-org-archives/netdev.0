From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v9 06/15] mlx5: Replace PCI pool old API
Date: Tue, 23 May 2017 10:27:43 +0300
Message-ID: <20170523072743.GJ17751@mtr-leonro.local>
References: <20170522164907.22915-1-romain.perier@collabora.com>
 <20170522164907.22915-7-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="/Gk0KcsbyUMelFU1"
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
Received: from mail.kernel.org ([198.145.29.99]:40990 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762152AbdEWH1s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 03:27:48 -0400
Content-Disposition: inline
In-Reply-To: <20170522164907.22915-7-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/Gk0KcsbyUMelFU1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 22, 2017 at 06:48:58PM +0200, Romain Perier wrote:
> The PCI pool API is deprecated. This commit replaces the PCI pool old
> API by the appropriate function with the DMA pool API.
>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Acked-by: Doug Ledford <dledford@redhat.com>
> Tested-by: Doug Ledford <dledford@redhat.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
>  include/linux/mlx5/driver.h                   |  2 +-
>  2 files changed, 7 insertions(+), 6 deletions(-)
>

Who is supposed to merge this patch series?

Acked-by: Leon Romanovsky <leonro@mellanox.com>

--/Gk0KcsbyUMelFU1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkj5G8ACgkQ5GN7iDZy
WKen5BAAy/3mvGSpTP8qDRSTN+YZtXD5my5DkkPXxjkjJ8Pp6mnHS83Ez6DuL8QT
s1x/XurCYGqXoKqaMiSx+nHKq7zirCnLG+MEelvkEXSZ1bTpLTfQYEX4Sq6Dp3Wz
gq5BkQl31V4Pgi9EuO24fhHxXNU8U0GXN0f97EHaa7X1OXUpSJChpsQjBVrD1K1R
8kvu3FO8Pj7XrFCRStNjnGyUkWxFr4wI4f0SouuSJ8uyQHE7yoe2k/wj/vCj4b1u
Q/olXUx3Q/uo1w003q2sHQQkq+aP8+j5fCTLA8eVIAEEWR8wUrTZ8bh7/ROwWJZf
VWIPjByvRQp1tnMukQfkh8WwlyjpWXsVxonRly1Nb0ZDMbp5TOHaMgJg/VY5n7cW
FKVZ1kHy8xFhtdT/b19HfaFcn3RAObrrU/BeEI3AiLvgxKJ0XE8xc4sfwaTjEtQa
3bOioETPWCRebQf+W63gUSLZM5Voj46+wiYBjQNpAOw2wjIuyfnt6MwWZamTBhVI
ST5Lrhw9aIK2//JFbbd4IxVwcrHTxSUXWswqig784im/CBw44m785IHPZP5LFPOl
Py9/rSQ8lj2kBr4jZ/ZKZTf4nqxjVAck2PJ77zdMFln68n37u6INCItxIGOA26Fm
yOZkqsmDWcgXRrv/BmY3/gbxfgX+99dbySWhjrS+5Hs3mEc2nlc=
=QF6J
-----END PGP SIGNATURE-----

--/Gk0KcsbyUMelFU1--
