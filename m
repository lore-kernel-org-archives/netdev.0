From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net-next v3 4/4] MAINTAINERS: add Sean/Nelson as MediaTek
 ethernet maintainers
Date: Mon, 31 Jul 2017 13:27:58 +0200
Message-ID: <20bbc086-58c2-637d-2040-edd72e2b43c2@phrozen.org>
References: <cover.1501494522.git.sean.wang@mediatek.com>
 <68f201bdb4a45d376611b036b611a1d6bbdbe336.1501494522.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com, Nelson Chang <nelson.chang@mediatek.com>
To: sean.wang@mediatek.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <68f201bdb4a45d376611b036b611a1d6bbdbe336.1501494522.git.sean.wang@mediatek.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 31/07/17 12:05, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
>
> Sean and Nelson work for MediaTek on maintaining the MediaTek ethernet
> driver for the existing SoCs and adding support for the following SoCs.
> In the past, Sean has been active at making most of the qualifications
> , stress test and submitting a lot of patches for the driver while
> Nelson was looking into the aspects more on hardware additions and details
> such as introducing PDMA with Hardware LRO to the driver. Also update
> John's up-to-date mail address in the patch.
>
> Cc: John Crispin <john@phrozen.org>
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>

Acked-by: John Crispin <john@phrozen.org>

> ---
>   MAINTAINERS | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index bd22d07..22faf704 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -8431,7 +8431,9 @@ F:	include/uapi/linux/uvcvideo.h
>   
>   MEDIATEK ETHERNET DRIVER
>   M:	Felix Fietkau <nbd@openwrt.org>
> -M:	John Crispin <blogic@openwrt.org>
> +M:	John Crispin <john@phrozen.org>
> +M:	Sean Wang <sean.wang@mediatek.com>
> +M:	Nelson Chang <nelson.chang@mediatek.com>
>   L:	netdev@vger.kernel.org
>   S:	Maintained
>   F:	drivers/net/ethernet/mediatek/
