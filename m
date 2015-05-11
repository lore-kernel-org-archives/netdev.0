From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [net-next PATCH v3 1/4] devicetree: Add compatible string for
 Zynq Ultrascale+ MPSoC
Date: Mon, 11 May 2015 09:41:50 +0200
Message-ID: <55505D3E.2050303@atmel.com>
References: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 06/05/2015 18:57, Harini Katakam a =E9crit :
> Add "cdns,zynqmp-gem" to be used for Zynq Ultrascale+ MPSoC.
>=20
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>

I know it's too late, but for the record:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks for having re-spinned this series Harini.

Bye,


> ---
>=20
> v3:
> No changes
>=20
> v2:
> Updated SoC name
>=20
> ---
>  Documentation/devicetree/bindings/net/macb.txt |    1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documen=
tation/devicetree/bindings/net/macb.txt
> index ba19d67..8ec5fdf 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -9,6 +9,7 @@ Required properties:
>    the Cadence GEM, or the generic form: "cdns,gem".
>    Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama5=
d3 SoCs.
>    Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama5=
d4 SoCs.
> +  Use "cdns,zynqmp-gem" for Zynq Ultrascale+ MPSoC.
>  - reg: Address and length of the register set for the device
>  - interrupts: Should contain macb interrupt
>  - phy-mode: See ethernet.txt file in the same directory.
>=20


--=20
Nicolas Ferre
