From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [net-next PATCH 1/3] devicetree: Add compatible string for Zynq
 Ultrascale MPSoC
Date: Fri, 10 Apr 2015 11:41:48 +0200
Message-ID: <d9d4238d-c8f7-4b15-8ba5-22d77be05a45@BN1AFFO11FD041.protection.gbl>
References: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>,
	<nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2015 11:17 AM, Harini Katakam wrote:
> Add "cdns,zynqmp-gem" to be used for Zynq Ultrascal MPSoc.

type here. And look below.

> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> ---
>  Documentation/devicetree/bindings/net/macb.txt |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index ba19d67..a112add 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -9,6 +9,7 @@ Required properties:
>    the Cadence GEM, or the generic form: "cdns,gem".
>    Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama5d3 SoCs.
>    Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama5d4 SoCs.
> +  Use "cdns,zynqmp-gem" for Zynq Ultrascale MPSoC.

Please use official name
Zynq UltraScale+ MPSoC

Thanks,
Michal
