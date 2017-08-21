From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V4 net-next] net: hns3: Add support to change MTU in HNS3
 hardware
Date: Mon, 21 Aug 2017 17:48:38 +0300
Message-ID: <20170821144838.GO1724@mtr-leonro.local>
References: <20170821144003.49436-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="O3WNCzIuUImKerqE"
Cc: davem@davemloft.net, yisen.zhuang@huawei.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821144003.49436-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--O3WNCzIuUImKerqE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 21, 2017 at 03:40:03PM +0100, Salil Mehta wrote:
> This patch adds the following support to the HNS3 driver:
> 1. Support to change the Maximum Transmission Unit of a
>    port in the HNS NIC hardware.
> 2. Initializes the supported MTU range for the netdevice.
>
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> ---
> PATCH V4: Addressed some minor comments Leon Romanovsky
>           1. https://lkml.org/lkml/2017/8/21/212
> PATCH V3: Addressed some minor comments Leon Romanovsky
>           1. https://lkml.org/lkml/2017/8/20/27
> PATCH V2: Addresses comments given by Andrew Lunn
>           1. https://lkml.org/lkml/2017/8/18/282
> PATCH V1: Initial Submit
> ---
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 34 ++++++++++++++++++++++
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  1 +
>  2 files changed, 35 insertions(+)
>

Wrong error code is not "minor" comment.

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--O3WNCzIuUImKerqE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlma8sYACgkQ5GN7iDZy
WKeu9BAAiF89hG7tAcXy3nKRWut8pVA5vJxormWlWaDzGUiAfckIAtRCKPLhOxJT
ElwMJHSy4AFzx6hB+WMfbH/HR03r9xAhWiVcxqEiQ4Ky3RCXHd5sFk7WAOkFR233
hfua2r4oQqihL3tesFjWPLNLheBinOPK62DlEfj35C2uS3m++n74FVHHTL3k2oZg
rnyblChoLcswtpExKzO4d5KuLCRqefurzb3H7Wzjued+SY+5dw2qL1wRNSXk1F7a
rCHGOlNGyCXvaF1DPJJNS+mtqxlFKDgDI5F2DBwQimELCjor6TxFNvXN/VULO5LM
YcPzuzfG94hDkD+GVie/x+qmsag+SNwr/VsPx8xrSlJGOq0fXf6o17g4B6EO712t
qkoJHduZWHaS6wbEc6zK/XJblVstE1lkNC6PD2K3sGz81AxiD/ttadPZbg27PXfX
CgN57tukaRcgc3vBS9ED99DpI02RkMVS2ClghLRguUZojofJIt+Gek1vlCye+POl
52Eb+gyTlR4NBdQLFoAiGXEMEWdLkQTnKRzHBiTBWTM8tTRy7Wxce1xkC2zS6QCw
iKUa+mLHs9DHq0k6iihRQp30MV26w55XMfBHodNspgmYuGnne8KRZvDa2euwCevu
EM9a418HTBUlELkAvQm9zJFKyfUrlztALE6Q1C1sLTzFvqv7Ddk=
=4h86
-----END PGP SIGNATURE-----

--O3WNCzIuUImKerqE--
