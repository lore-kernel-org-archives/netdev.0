From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 1/3] net: macb: Document zynq gem dt binding
Date: Fri, 22 May 2015 16:56:42 +0200
Message-ID: <555F43AA.4080502@atmel.com>
References: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 22/05/2015 16:22, Nathan Sullivan a =E9crit :
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  Documentation/devicetree/bindings/net/cdns-emac.txt |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/cdns-emac.txt b/Do=
cumentation/devicetree/bindings/net/cdns-emac.txt
> index abd67c1..4451ee9 100644
> --- a/Documentation/devicetree/bindings/net/cdns-emac.txt
> +++ b/Documentation/devicetree/bindings/net/cdns-emac.txt
> @@ -3,7 +3,8 @@
>  Required properties:
>  - compatible: Should be "cdns,[<chip>-]{emac}"
>    Use "cdns,at91rm9200-emac" Atmel at91rm9200 SoC.
> -  or the generic form: "cdns,emac".
> +  Use "cdns,zynq-gem" Xilinx Zynq-7xxx SoC.
> +  Or the generic form: "cdns,emac".
>  - reg: Address and length of the register set for the device
>  - interrupts: Should contain macb interrupt
>  - phy-mode: see ethernet.txt file in the same directory.
>=20


--=20
Nicolas Ferre
