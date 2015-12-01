From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2 net-next] ravb: Add fallback compatibility strings
Date: Tue, 1 Dec 2015 13:26:08 +0300
Message-ID: <565D75C0.1020502@cogentembedded.com>
References: <1448955783-22806-1-git-send-email-horms+renesas@verge.net.au>
 <1448955783-22806-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, devicetree@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1448955783-22806-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/1/2015 10:43 AM, Simon Horman wrote:

> Add fallback compatibility strings for R-Car Gen 2 & 3 SoC Families.
> This is in keeping with the fallback scheme being adopted wherever
> appropriate for drivers for Renesas SoCs.
>
> Also correct typo.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>   Documentation/devicetree/bindings/net/renesas,ravb.txt | 11 +++++++++--
>   drivers/net/ethernet/renesas/ravb_main.c               |  2 ++
>   2 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index b486f3f5f6a3..115006325bff 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -1,12 +1,19 @@
>   * Renesas Electronics Ethernet AVB
>
>   This file provides information on what the device node for the Ethernet AVB
> -interface contains.
> +interface.

    Why?

[...]

MBR, Sergei

